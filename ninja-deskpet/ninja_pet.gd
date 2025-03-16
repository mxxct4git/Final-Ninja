extends Node2D

# Gemini API Configuration
const GEMINI_API_URL = "<Your Gemini API URL>" # You need to set your Gemini API URL
var api_key = "<Your Gemini API Key>" # You need to set your Gemini API Key

# Add to the variable declaration section
var countdown_bar: ProgressBar
var max_time: float = 1800.0  # 30 minutes countdown
var current_time: float = 1800.0

# Add to the variable declaration section at the beginning of the file
var countdown_label: Label

# Smart music service URL
const CHATJAMS_URL = "https://www.chatjams.ai/playlist/"

# Preset dialog content (English)
var dialogues = [
	"👋 Hi, I'm Final Ninja! My mission is to help people pass the final week.",
	"📚 I noticed you're struggling with your exams. Don't worry, I'm here to help!",
	"⏱️ We have 48 hours to prepare efficiently for your finals.",
	"💪 But we need to defeat the Final Monster together to succeed!",
	"🤔 What can I help you with? (Type 'plan' for AI genrated study plan, 'quiz' for testing your knowledge, 'music' for generated playlist, 'adhd' for ADHD Reader Mode, or 'ranking' to check your ranking at ninja community)"
]

# AI-style thinking phrases
var thinking_phrases = [
	"🧠 Analyzing your learning patterns...",
	"🔍 Identifying knowledge gaps...",
	"✨ Crafting the optimal strategy...",
	"🔢 Calculating the most efficient approach...",
	"🎯 Preparing personalized recommendations..."
]

# Study plan related prompts
var study_plan_dialogue = [
	"📅 Let's create a 48-hour study plan to conquer your finals!",
	"🧩 Based on your learning style, I recommend focusing on difficult topics first.",
	"🏆 We'll tackle the hardest parts, then consolidate, and finally do practice tests.",
	"⚡ Remember: strategic breaks are crucial for optimal learning!"
]

# Music keywords and descriptions
var music_keywords = [
	{
		"keyword": "focus",
		"description": "Music to help you concentrate and study"
	},
	{
		"keyword": "chill",
		"description": "Relaxing beats to unwind and destress"
	},
	{
		"keyword": "energetic",
		"description": "Upbeat tunes to boost your energy"
	},
	{
		"keyword": "ambient",
		"description": "Atmospheric sounds for deep work"
	},
	{
		"keyword": "jazz",
		"description": "Smooth jazz for a sophisticated atmosphere"
	}
]

# Music playlist list
var focus_playlists = [
	{
		"name": "Deep Focus",
		"description": "Perfect for intense study sessions",
		"url": "https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ"
	},
	{
		"name": "Brain Food",
		"description": "Atmospheric electronica for focus",
		"url": "https://open.spotify.com/playlist/37i9dQZF1DWXLeA8Omikj7"
	},
	{
		"name": "Lo-Fi Beats",
		"description": "Chill beats to help you focus",
		"url": "https://open.spotify.com/playlist/37i9dQZF1DWWQRwui0ExPn"
	},
	{
		"name": "Peaceful Piano",
		"description": "Relaxing piano music for concentration",
		"url": "https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO"
	}
]

var courses = [
	"FIT9131 - Programming foundations in Java",
	"FIT9132 - Introduction to databases",
	"FIT9136 - Introduction to Python programming",
	"FIT9137 - Introduction to computer architecture and networks"
]

# Health reminder messages
var health_reminders = [
	"⏰ You've been studying for 2 hours straight! Time for a 5-minute break.",
	"💧 Remember to stay hydrated! Grab some water and stretch a bit.",
	"👁️ Your eyes need rest - look at something 20 feet away for 20 seconds.",
	"🚶 Stand up and move around for a few minutes to boost your circulation!",
	"🧠 Mental fatigue detected! A 10-minute break now will improve your productivity."
]

var current_dialogue_index = 0  # Current dialogue index
var user_input_mode = false  # Whether in user input mode
var conversation_history = []  # Conversation history
var is_showing_music = false   # Whether currently displaying music feature
var is_typing_text = false     # Whether executing typing effect
var typing_speed = 0.02        # Typing speed (seconds/character)
var current_display_text = ""  # Current display text
var full_text_to_display = ""  # Complete text to display
var typing_timer = 0.0         # Typing timer
var custom_playlist_mode = false # Whether in custom playlist mode
var study_time_start = 0       # Study start time
var health_reminder_timer = 0  # Health reminder timer
var music_option_selection_pending = false # Whether waiting for music option selection

# Animation states - based on existing animation resources
enum AnimState {IDLE, TALKING, THINKING, HAPPY, DANGER}
var current_anim_state = AnimState.IDLE

# Increase window movement speed variable
var window_move_speed = 40 # Increased from 30 to 40, pixels moved per key press

# Add simulated ranking data
var ninja_rankings = [
	{
		"name": "Final Ninja",
		"avatar": "🥷",
		"study_time": "42 hours",
		"status": "Master Focus",
		"level": 9,
		"is_user": true
	},
	{
		"name": "Fox Ninja",
		"avatar": "🦊",
		"study_time": "47 hours",
		"status": "Deep Learning",
		"level": 10,
		"is_user": false
	},
	{
		"name": "Hello Kitty Ninja",
		"avatar": "😺",
		"study_time": "53 hours",
		"status": "Cute Concentration",
		"level": 11,
		"is_user": false
	},
	{
		"name": "Quokka Ninja",
		"avatar": "🐹",
		"study_time": "36 hours",
		"status": "Happy Studying",
		"level": 8,
		"is_user": false
	},
	{
		"name": "Wombat Ninja",
		"avatar": "🦝",
		"study_time": "33 hours",
		"status": "Night Explorer",
		"level": 7,
		"is_user": false
	},
	{
		"name": "Tiger Ninja",
		"avatar": "🐯",
		"study_time": "51 hours",
		"status": "Ultimate Focus",
		"level": 12,
		"is_user": false
	},
	{
		"name": "Panda Ninja",
		"avatar": "🐼",
		"study_time": "38 hours",
		"status": "Bamboo Scholar",
		"level": 8,
		"is_user": false
	},
	{
		"name": "Bunny Ninja",
		"avatar": "🐰",
		"study_time": "44 hours",
		"status": "Quick Learner",
		"level": 9,
		"is_user": false
	}
]

# Initialization
func _ready():
	print("Initialization started...")
	
	# Set transparent background - more comprehensive settings
	get_window().transparent_bg = true
	
	# Set clear color to completely transparent
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 0))
	
	# Ensure the scene background is transparent
	var root_viewport = get_tree().root
	root_viewport.transparent_bg = true
	
	# Initialize dialog box
	var dialog_panel = $CanvasLayer/DialogPanel
	dialog_panel.visible = false
	
	# Set dialog box style - increase size to fit content
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	dialog_label.size = Vector2(700, 800) # Increase width and height to better fill the panel
	dialog_label.position = Vector2(10, 10) # Reduce margins
	dialog_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_label.add_theme_font_size_override("font_size", 40) # Increase default font size
	
	# Create panel style and set transparent background
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(1, 1, 1, 0.5)  # White semi-transparent background
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1, 1, 1, 0.9)  # Border color is white
	panel_style.shadow_color = Color(0, 0, 0, 0.5)  # Shadow color
	panel_style.shadow_size = 15
	panel_style.shadow_offset = Vector2(0, 4)

	# Apply custom style to dialog panel
	dialog_panel.add_theme_stylebox_override("panel", panel_style)
	# Optional: Adjust transparency to enhance frosted glass effect
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)  # Set semi-transparent background
	dialog_panel.add_theme_stylebox_override("panel", panel_style)
	# Optional: Use blurred background image as background (if stronger frosted glass effect is needed)
	#var background = TextureRect.new()
	#background.texture = load("Users/mustang/Downloads/cybercity.jpeg")  # Blurred background image
	#background.expand = true  # Stretch to fill background
	#dialog_panel.add_child(background)  # Add background to dialog box

	# Initialize countdown progress bar
	countdown_bar = $CanvasLayer/DialogPanel/ProgressBar
	countdown_label = $CanvasLayer/DialogPanel/CountdownLabel
	if countdown_bar:
		countdown_bar.max_value = max_time
		countdown_bar.value = current_time
		countdown_bar.show_percentage = false  # Disable percentage display
		
		# Set progress bar style
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # Background color
		style.set_corner_radius_all(8)  # Rounded corners
		countdown_bar.add_theme_stylebox_override("background", style)
		
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color(0.3, 0.8, 0.3, 1.0)  # Fill color
		fill_style.set_corner_radius_all(8)  # Rounded corners
		countdown_bar.add_theme_stylebox_override("fill", fill_style)
	
	if countdown_label:
		countdown_label.add_theme_font_size_override("font_size", 28)
		countdown_label.add_theme_color_override("font_color", Color(1, 1, 1))
	
	# Initialize user input box style
	var input_box = $CanvasLayer/DialogPanel/InputContainer
	input_box.visible = false
	
	# Add modern style to the input field
	var input_field = $CanvasLayer/DialogPanel/InputContainer/InputBox
	if input_field:
		var input_style = StyleBoxFlat.new()
		input_style.bg_color = Color(0.12, 0.12, 0.2, 0.8) 
		input_style.corner_radius_top_left = 10
		input_style.corner_radius_top_right = 10
		input_style.corner_radius_bottom_left = 10
		input_style.corner_radius_bottom_right = 10
		input_style.border_width_left = 1
		input_style.border_width_top = 1
		input_style.border_width_right = 1
		input_style.border_width_bottom = 1
		input_style.border_color = Color(0.3, 0.7, 1.0, 0.6)
		input_field.add_theme_stylebox_override("normal", input_style)
		
		# Set input field text color and font size
		input_field.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		input_field.add_theme_font_size_override("font_size", 20) # Increase input field font size
	
	# Preload all animations
	preload_animations()
	
	# Start animation
	change_animation(AnimState.IDLE)
	print("Initialization completed")
	
	# Start AI startup sequence
	await get_tree().create_timer(0.5).timeout
	show_next_dialogue()
	
# Preload animations to ensure smooth playback
func preload_animations():
	# Ensure all animations are created in AnimationPlayer
	# This just checks if they exist, actual creation should be done in the editor
	if not $AnimationPlayer.has_animation("idle"):
		print("Warning: 'idle' animation not found!")
	if not $AnimationPlayer.has_animation("talking"):
		print("Warning: 'talking' animation not found!")
	if not $AnimationPlayer.has_animation("thinking"):
		print("Warning: 'thinking' animation not found!")
	if not $AnimationPlayer.has_animation("happy"):
		print("Warning: 'happy' animation not found!")
	if not $AnimationPlayer.has_animation("danger"):
		print("Warning: 'danger' animation not found!")
	
# Add _input function as a backup click detection method


func _process(delta):
	# Update countdown
	if countdown_bar and current_time > 0:
		current_time -= delta / 1  # Convert to seconds
		countdown_bar.value = current_time
		
		# Update progress bar color
		if current_time <= 300:  # Less than or equal to 5 minutes (300 seconds)
			var fill_style = StyleBoxFlat.new()
			fill_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Red
			fill_style.set_corner_radius_all(8)  # Keep rounded corners
			countdown_bar.add_theme_stylebox_override("fill", fill_style)
		
		# Update displayed text
		if countdown_label:
			var minutes = int(current_time) / 60
			var seconds = int(current_time) % 60
			countdown_label.text = "%d:%02d" % [minutes, seconds]

	# Ensure background remains transparent
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 0))
	
	# Ensure animation plays continuously
	if not $AnimationPlayer.is_playing():
		match current_anim_state:
			AnimState.IDLE:
				$AnimationPlayer.play("idle")
			AnimState.TALKING:
				$AnimationPlayer.play("talking")  # Use talking animation for speaking
			AnimState.THINKING:
				$AnimationPlayer.play("thinking")  # Use thinking animation for thinking
			AnimState.HAPPY:
				$AnimationPlayer.play("happy")  # Use happy animation for happiness
			AnimState.DANGER:
				$AnimationPlayer.play("danger")  # Use danger animation for dangerous situation
	
	# Handle typing effect
	if is_typing_text:
		typing_timer += delta
		if typing_timer >= typing_speed:
			typing_timer = 0.0
			if current_display_text.length() < full_text_to_display.length():
				current_display_text += full_text_to_display[current_display_text.length()]
				# Add null check
				var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
				if dialog_label and is_instance_valid(dialog_label):
					dialog_label.text = current_display_text
			else:
				is_typing_text = false
	
	# Handle health reminder
	if study_time_start > 0:
		health_reminder_timer += delta
		# Every 30 minutes (1800 seconds)
		if health_reminder_timer >= 1800:
			health_reminder_timer = 0
			show_health_reminder()

# Change animation state
func change_animation(new_state):
	current_anim_state = new_state
	
	match new_state:
		AnimState.IDLE:
			$AnimationPlayer.play("idle")
		AnimState.TALKING:
			$AnimationPlayer.play("talking")  # Use talking animation for speaking
		AnimState.THINKING:
			$AnimationPlayer.play("thinking")  # Use thinking animation for thinking
		AnimState.HAPPY:
			$AnimationPlayer.play("happy")  # Use happy animation for happiness
		AnimState.DANGER:
			$AnimationPlayer.play("danger")  # Use danger animation for dangerous situation

# Display text with typing effect
func display_text_with_typing_effect(text):
	is_typing_text = true
	current_display_text = ""
	full_text_to_display = text
	typing_timer = 0.0
	
	# Ensure DialogLabel exists and font size is correct
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		if not dialog_label is RichTextLabel:
			dialog_label.add_theme_font_size_override("font_size", 24) # Ensure using new font size

# Show next dialogue
func show_next_dialogue():
	print("Showing dialogue: ", current_dialogue_index)
	if user_input_mode or is_showing_music or is_typing_text:
		return
		
	if current_dialogue_index < dialogues.size():
		# Show dialog box
		$CanvasLayer/DialogPanel.visible = true
		
		# Update dialogue content - use typing effect
		display_text_with_typing_effect(dialogues[current_dialogue_index])
		current_dialogue_index += 1
		
		# Switch to speaking animation
		change_animation(AnimState.TALKING)
		
		# Wait for a while before returning to idle state
		await get_tree().create_timer(2.5).timeout
		change_animation(AnimState.IDLE)
	else:
		# Dialogue ended, show user input interface
		show_user_input()

# Show user input interface
func show_user_input():
	user_input_mode = true
	custom_playlist_mode = false
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# If focus jazz mode, show special text
	var user_input = $CanvasLayer/DialogPanel/InputContainer/InputBox
	if user_input.text == "focus jazz" || user_input.text == "ninja vibe":
		display_text_with_typing_effect("Creating a '" + user_input.text + "' playlist for you!.")
		# Switch to speaking animation
		change_animation(AnimState.TALKING)
		await get_tree().create_timer(2.0).timeout
		# Directly call music generation function
		generate_custom_playlist(user_input.text)
		return
	# If this is the first time showing user input interface, show full dialogue content
	elif current_dialogue_index == dialogues.size() and current_display_text.strip_edges().is_empty():
		# Get last dialogue content
		var last_dialogue = dialogues[dialogues.size() - 1]
		# Add input prompt
		var prompt_text = last_dialogue + "\n\n(✍️ Please type your question or command...)"
		display_text_with_typing_effect(prompt_text)
	else:
		# If there is already dialogue content being displayed, check if input prompt is already included
		if not is_typing_text and current_display_text.length() > 0:
			var current_text = current_display_text
			# Check if input prompt is already included
			if not "(Type " in current_text and not "(Please type" in current_text and not "(✍️" in current_text:
				current_text += "\n\n(✍️ Type your next question or command...)"
				display_text_with_typing_effect(current_text)
		elif current_display_text.strip_edges().is_empty():
			# If no content is being displayed, show a basic prompt
			display_text_with_typing_effect("🤔 What can I help you with? (Type 'plan' for study plan, 'test' for practice, or 'music' for focus music)")
	
	# Wait for typing effect to complete
	await get_tree().create_timer(1.0).timeout
	
	# Show input container
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# Switch to idle animation
	change_animation(AnimState.IDLE)

# Handle user input
func _on_send_button_pressed():
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	var user_message = input_box.text
	print(">>>> User current input: " + user_message)

	if user_message.strip_edges().length() > 0:
		# Hide input box
		$CanvasLayer/DialogPanel/InputContainer.visible = false
		
		# Record current mode status before processing input (for debugging)
		print("Processing user input, mode status:")
		print("- custom_playlist_mode: ", custom_playlist_mode)
		print("- is_showing_music: ", is_showing_music)
		print("- user_input_mode: ", user_input_mode)
		print("- music_option_selection_pending: ", music_option_selection_pending)
		
		# Check for general return command
		var lower_message = user_message.to_lower().strip_edges()
		if lower_message == "back" or lower_message == "menu":
			print("User requested to return to main menu")
			custom_playlist_mode = false
			is_showing_music = false
			music_option_selection_pending = false
			show_user_input()
			return
		
		# Check if it's a course selection
		if user_message.is_valid_int():
			var course_index = user_message.to_int() - 1
			if course_index >= 0 and course_index < courses.size():
				show_study_plan()  # Show study plan for selected course
				return

		# First check if waiting for music option selection
		if music_option_selection_pending:
			print("Processing music option selection: ", user_message)
			music_option_selection_pending = false  # Reset flag
			
			var choice = user_message.strip_edges()
			if choice == "1":
				show_music_playlists()
			elif choice == "2":
				print("User selected option 2, calling show_custom_playlist_interface()")
				show_custom_playlist_interface()
			elif choice == "3":
				print("User selected to return to main menu")
				is_showing_music = false
				show_user_input()
			else:
				print("User entered other content, returning to conversation mode")
				is_showing_music = false
				show_user_input()
			return
		
		# Check for special commands
		elif lower_message == "ranking":
			show_ninja_ranking()
		elif lower_message == "music":
			show_music_options()
		elif lower_message == "plan":
			# First check course list
			show_course_selection()
		elif lower_message == "9136":
			# Show course learning summary + plan
			show_study_plan()
		elif lower_message == "quiz":
			show_practice_test()
		elif lower_message == "health":
			show_health_tip()
		elif lower_message == "adhd":
			show_adhd_reader_mode()
		elif lower_message == "1b 2a 3c":
			# Process user answers
			process_quiz_answer()
		else:
			# Handle general user input
			process_user_input(user_message)

# Process user quiz answers
func process_quiz_answer():
	is_showing_music = false
	user_input_mode = false
	
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# Play thinking animation
	change_animation(AnimState.THINKING)
	
	# Display evaluation message
	display_text_with_typing_effect("🤔 Evaluating your answers...")
	
	# Wait for a short time to display animation effect
	await get_tree().create_timer(1.5).timeout
	
	# User answers and correct answers
	var user_answers = "1b 2a 3c"
	var correct_answers = "1b 2a 3c"
	var score = 3  # Full score, as answers are completely matched
	
	# Answer explanation
	var explanations = {
		"1": "✅ Correct! Variable names cannot start with numbers. '2nd_number' is an invalid variable name.",
		"2": "✅ Correct! In Python, using the 'def' keyword is the correct syntax for defining functions.",
		"3": "✅ Correct! In Python, both class definition methods are valid."
	}
	
	# Build result text
	var result_text = "📝 Quiz Results:\n\n"
	result_text += "🌟 Perfect! You got all questions right!\n\n"
	result_text += "Detailed Explanations:\n"
	
	# Add explanation for each question
	for i in range(1, 4):
		result_text += str(i) + ". " + explanations[str(i)] + "\n\n"
	
	# Add encouraging feedback
	result_text += "💪 Excellent! You've mastered these fundamental concepts.\n"
	result_text += "Ready for the next challenge?\n\n"
	result_text += "✍️ Type your next question or command..."
	
	# Switch to happy animation
	change_animation(AnimState.HAPPY)
	
	# Display result
	display_text_with_typing_effect(result_text)
	
	# Delay before showing input interface
	await get_tree().create_timer(2.0).timeout
	show_user_input()

# Show music options
func show_music_options():
	is_showing_music = true
	user_input_mode = false
	custom_playlist_mode = false  # Ensure reset at the start
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# Display loading message, giving UI time to update
	display_text_with_typing_effect("🎵 Loading music options...")
	
	# Play happy animation
	change_animation(AnimState.HAPPY)
	
	# Wait for a short time to ensure UI updates
	await get_tree().create_timer(0.5).timeout
	
	# Create a more concise modern menu, avoiding overlap and encoding issues
	var menu_text = "[center][color=#3498db][font_size=22]🎧 Music Options[/font_size][/color][/center]\n\n"
	
	menu_text += "[color=#e74c3c]1.[/color] [url=option_1][color=#f1c40f]🎶 Browse Spotify Playlists[/color][/url]\n"
	menu_text += "   Discover curated playlists for studying\n\n"
	
	menu_text += "[color=#e74c3c]2.[/color] [url=option_2][color=#f1c40f]✨ Generate Custom Playlist[/color][/url]\n"
	menu_text += "   Create a playlist based on your mood\n\n"
	
	menu_text += "[color=#e74c3c]3.[/color] [url=option_3][color=#f1c40f]🏠 Return to Main Menu[/color][/url]\n"
	menu_text += "   Go back to the main options\n\n"
	
	menu_text += "[color=#7f8c8d]Click any option or type 1, 2, or 3[/color]"
	
	# Completely clear and redisplay
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # Ensure first clear
	
	# Display introduction text with menu
	display_text_with_rich_text("🎵 I can help you find some music to enhance your study session!\n\n" + menu_text)
	
	# Switch to speaking animation
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# Show input container
	await get_tree().create_timer(0.5).timeout
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# Set flag
	music_option_selection_pending = true
	user_input_mode = true

# Generate custom playlist
func generate_custom_playlist(keywords):
	print("Generating custom playlist with keywords: ", keywords)
	
	# Check if it's a return command
	if keywords.to_lower().strip_edges() == "back":
		print("User requested to go back to music menu")
		custom_playlist_mode = false
		show_music_options()
		return
	
	# Set mode flag
	custom_playlist_mode = false  # Exit playlist mode after generation
	is_showing_music = true
	user_input_mode = false
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Display initial generation message
	display_text_with_typing_effect("🎵 Starting to analyze your music preferences: \"" + keywords + "\"...")
	
	# Switch to thinking animation
	change_animation(AnimState.THINKING)
	
	# Wait for typing effect to complete
	await get_tree().create_timer(1.0).timeout
	
	# Display AI generation process
	var generation_steps = [
		"🔍 Analyzing keyword characteristics...",
		"🧠 Matching music style database...",
		"✨ Applying rhythm preference algorithm...",
		"🎧 Evaluating emotional expression parameters...",
		"📊 Calculating optimal track combinations..."
	]
	
	# Display each step of the generation process
	for step in generation_steps:
		display_text_with_typing_effect(step)
		await get_tree().create_timer(randf_range(0.5, 1.2)).timeout
	
	# Display generation status
	display_text_with_typing_effect("🚀 Generation progress: 0%")
	await get_tree().create_timer(0.7).timeout
	display_text_with_typing_effect("🚀 Generation progress: 25%")
	await get_tree().create_timer(0.8).timeout
	display_text_with_typing_effect("🚀 Generation progress: 58%")
	await get_tree().create_timer(0.6).timeout
	display_text_with_typing_effect("🚀 Generation progress: 87%")
	await get_tree().create_timer(0.9).timeout
	display_text_with_typing_effect("🚀 Generation progress: 100%")
	await get_tree().create_timer(0.5).timeout
	
	# Get playlist URL and title - based on keyword match
	var playlist_url = ""
	var playlist_title = ""
	var playlist_description = ""
	var playlist_tracks = []
	var lower_keywords = keywords.to_lower().strip_edges()
	
	# Create "generated" playlists for different keywords
	if "focus" in lower_keywords and "jazz" in lower_keywords:
		playlist_url = "https://open.spotify.com/playlist/6KwnuHhfXRWyAaW42Qe0bD"
		playlist_title = "Jazz Focus Vibes"
		playlist_description = "Immersive jazz designed to enhance attention and focus"
		playlist_tracks = [
			"Blue in Green - Miles Davis",
			"Take Five - Dave Brubeck",
			"Autumn Leaves - Bill Evans",
			"So What - Miles Davis",
			"Moanin' - Art Blakey"
		]
	
	elif ("ninja" in lower_keywords and ("final" in lower_keywords or "week" in lower_keywords)) or "ninja vibe" in lower_keywords:
		playlist_url = "https://open.spotify.com/playlist/54YDhl5w0CsXHBAagmWU7O"
		playlist_title = "Ninja Rhythms: Focus & Flow"
		playlist_description = "Dynamic rhythms customized for final week sprint, igniting your inner ninja spirit"
		playlist_tracks = [
			"Night Prowler - Lo-Fi Expert",
			"Shadow Warriors - Study Beat",
			"Final Week Energy - Focus Master",
			"Silent Movement - Concentration Wave",
			"Ninja Mind - Exam Ready"
		]
	
	else:
		# Create a "custom" playlist based on keywords
		playlist_url = "https://open.spotify.com/playlist/37i9dQZF1DWWQRwui0ExPn"
		
		# Dynamically create playlist title
		var title_parts = []
		var keywords_array = lower_keywords.split(" ")
		for word in keywords_array:
			if word.length() > 3:  # Only use longer words
				title_parts.append(word.capitalize())
		
		if title_parts.size() > 0:
			playlist_title = " ".join(title_parts) + " Flow"
		else:
			playlist_title = "Personalized Focus Mix"
			title_parts = ["Focus"] # Add default value to prevent issues later
		
		playlist_description = "Custom playlist based on your keywords \"" + keywords + "\""
		
		# Generate some tracks that seem related to the keywords
		var track_templates = [
			"Deep NAME_PLACEHOLDER - Focus Artist",
			"NAME_PLACEHOLDER Rhythm - Study Master",
			"NAME_PLACEHOLDER Energy - Concentration",
			"NAME_PLACEHOLDER Journey - Mind Flow",
			"NAME_PLACEHOLDER Meditation - Brain Boost"
		]
		
		for template in track_templates:
			var track_name = template.replace("NAME_PLACEHOLDER", title_parts[randi() % title_parts.size()])
			playlist_tracks.append(track_name)
	
	# Switch to happy animation
	change_animation(AnimState.HAPPY)
	
	# Display "discovery" message
	display_text_with_typing_effect("✨ Perfect match found! Integrating playlist...")
	
	# Wait for a short time to build anticipation
	await get_tree().create_timer(1.0).timeout
	
	# Ensure dialog box is visible
	$CanvasLayer/DialogPanel.visible = true
	
	# Completely clear and redisplay
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # Ensure first clear
		dialog_label.clear()
	
	# Create more beautiful result display
	var header = "[center][color=#3498db][font_size=24]🎵 Your Custom Generated Playlist![/font_size][/color][/center]\n\n"
	
	var content = "[center][b][color=#e67e22][font_size=22]" + playlist_title + "[/font_size][/color][/b][/center]\n"
	content += "[center][i][color=#7f8c8d]" + playlist_description + "[/color][/i][/center]\n\n"
	
	# Add track list
	content += "[color=#2ecc71][font_size=18]Featured Tracks:[/font_size][/color]\n"
	for i in range(min(5, playlist_tracks.size())):
		content += "[color=#3498db]" + str(i+1) + ".[/color] " + playlist_tracks[i] + "\n"
	content += "\n"
	
	# Create larger and more obvious button style link
	content += "[center][url=" + playlist_url + "][color=#2ecc71][bgcolor=#1a1a2a][font_size=20]▶️  LISTEN ON SPOTIFY  ▶️[/font_size][/bgcolor][/color][/url][/center]\n\n"
	
	# Display actual link for easy copying
	content += "[center][color=#7f8c8d]" + playlist_url + "[/color][/center]\n\n"
	
	var footer = "[center][color=#e74c3c]🎧 This playlist was specially generated based on your keywords \"" + keywords + "\"[/color][/center]\n\n"
	footer += "[center][url=music_menu][color=#3498db]🔙 Back to Music Menu[/color][/url][/center]"
	
	# Display result
	display_text_with_rich_text(header + content + footer)
	
	# Switch to speaking animation
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# Delay before returning to conversation mode
	await get_tree().create_timer(2.0).timeout
	change_animation(AnimState.IDLE)

# Show custom playlist interface
func show_custom_playlist_interface():
	# Set mode flag
	custom_playlist_mode = true
	is_showing_music = true
	user_input_mode = false
	
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Display loading message, giving UI time to update
	display_text_with_typing_effect("✨ Loading AI Playlist Generator...")
	
	# Play thinking animation
	change_animation(AnimState.THINKING)
	
	# Wait for a short time to ensure UI updates
	await get_tree().create_timer(0.5).timeout
	
	# Build simplified keyword suggestion text
	var header = "[center][color=#3498db][font_size=22]🎮 AI Playlist Generator[/font_size][/color][/center]\n\n"
	var intro = "[color=#2ecc71]✨ Enter keywords or mood, and I'll generate the perfect study playlist for you:[/color]\n\n"
	var examples_section = "[color=#f1c40f]💡 Try these examples:[/color]\n"
	
	# Add example prompts
	examples_section += "[color=#e74c3c]•[/color] [b]focus jazz[/b] - Jazz music, perfect for enhancing focus\n"
	examples_section += "[color=#e74c3c]•[/color] [b]ninja vibe for final week[/b] - Dynamic rhythms for finals week\n"
	examples_section += "[color=#e74c3c]•[/color] [b]chill lofi[/b] - Relaxing Lo-Fi to help you study\n"
	examples_section += "[color=#e74c3c]•[/color] [b]classic piano study[/b] - Classical piano to aid your thinking\n\n"
	
	var suggestion = "[color=#f1c40f]💡 Other suggested keywords:[/color]\n"
	for keyword in music_keywords:
		suggestion += "[color=#e74c3c]•[/color] [b]" + keyword.keyword + "[/b] - " + keyword.description + "\n"
	
	var footer = "\n[color=#7f8c8d]💭 Enter any keywords you want, and AI will create a perfectly matched playlist for you![/color]\n\n"
	footer += "[url=back][color=#3498db]🔙 Back to Music Menu[/color][/url]"
	
	# Completely clear and redisplay
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # Ensure first clear
	
	# Display suggestion list
	display_text_with_rich_text(header + intro + examples_section + suggestion + footer)
	
	# Switch to speaking animation
	change_animation(AnimState.TALKING)
	
	# Wait for animation effect to complete
	await get_tree().create_timer(1.0).timeout
	
	# Show input container
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# Set user input mode, but maintain custom playlist mode
	user_input_mode = true
	custom_playlist_mode = true

# Show music playlists
func show_music_playlists():
	is_showing_music = true
	user_input_mode = false
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# Display loading message
	display_text_with_typing_effect("🔍 Finding the perfect study music for you...")
	
	# Play happy animation
	change_animation(AnimState.HAPPY)
	
	# Wait for animation and typing effect
	await get_tree().create_timer(1.5).timeout
	
	# Switch to speaking animation
	change_animation(AnimState.TALKING)
	
	# Wait for a short time to ensure UI updates
	await get_tree().create_timer(0.5).timeout
	
	# Build simplified playlist text
	var header = "[center][color=#3498db][font_size=22]🎵 Focus Playlists[/font_size][/color][/center]\n"
	header += "[color=#7f8c8d]Click any playlist to open in Spotify[/color]\n\n"
	
	var content = ""
	for i in range(focus_playlists.size()):
		var playlist = focus_playlists[i]
		content += str(i+1) + ". [b][color=#f1c40f]" + playlist.name + "[/color][/b]\n"
		content += "   " + playlist.description + "\n"
		content += "   [url=" + playlist.url + "][color=#3498db]▶️ Play on Spotify[/color][/url]\n\n"
	
	var footer = "[url=music_menu][color=#3498db]🔙 Back to Music Menu[/color][/url]"
	
	# Completely clear and redisplay
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # Ensure first clear
	
	# Display playlist list
	display_text_with_rich_text(header + content + footer)
	
	# Delay before returning to conversation mode
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.IDLE)

# Show course list
func show_course_selection():
	is_showing_music = false
	user_input_mode = true
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# Build course list text
	var course_text = "📚 Available Courses:\n\n"
	for i in range(courses.size()):
		course_text += str(i + 1) + ". " + courses[i] + "\n"
	
	course_text += "\n✍️ Please enter the course number (1-" + str(courses.size()) + ") to view study plan..."
	
	# Display course list
	display_text_with_typing_effect(course_text)
	
	# Show input container
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()

# Show study plan
func show_study_plan():
	is_showing_music = false
	user_input_mode = false
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Play thinking animation
	change_animation(AnimState.THINKING)
	
	# Display introduction text
	$CanvasLayer/DialogPanel.visible = true
	display_text_with_typing_effect("🧠 Analyzing your exam needs and creating a 48-hour study plan...")
	
	# Wait for typing effect to complete
	await get_tree().create_timer(3).timeout
	
	# Switch to happy animation
	change_animation(AnimState.HAPPY)
	
	# Get dialog label and set scrolling
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		# Ensure it's RichTextLabel
		if dialog_label is RichTextLabel:
			dialog_label.scroll_active = true  # Enable scrolling
			dialog_label.scroll_following = true  # Auto-scroll text
			dialog_label.scroll_to_line(0)  # Ensure starting from top
			dialog_label.custom_minimum_size = Vector2(610, 450)  # Set minimum size
			dialog_label.size = Vector2(610, 450)  # Set fixed size
			dialog_label.fit_content = false  # Disable content adaptation
			
			# Scrollbar settings
			dialog_label.scroll_horizontal_enabled = false  # Disable horizontal scrolling
			dialog_label.scroll_vertical_enabled = true  # Enable vertical scrolling
			dialog_label.scroll_vertical = 0  # Initial scroll position
			dialog_label.scroll_following_smoothing = 3  # Scroll smoothness
			dialog_label.scroll_vertical_custom_step = 30  # Custom scroll step
			
			# Scrollbar style (optional)
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.2, 0.2, 0.2, 0.6)  # Scrollbar background color
			style.corner_radius_top_left = 3
			style.corner_radius_top_right = 3
			style.corner_radius_bottom_left = 3
			style.corner_radius_bottom_right = 3
			dialog_label.add_theme_stylebox_override("scroll", style)

	# Display plan text
	var plan_text = "📚 FIT9136 Week 1 Summary\n\n"
	
	plan_text += "📋 Course Overview:\n"
	plan_text += "This week is all about getting you started with Python and understanding Big O Notation. "
	plan_text += "You'll learn how to analyze how fast your code runs as input size grows.\n\n"
	
	plan_text += "Key Topics:\n"
	plan_text += "• Python basics (variables, loops, and functions)\n"
	plan_text += "• Code efficiency analysis\n"
	plan_text += "• Understanding scaling and performance\n\n"
	
	plan_text += "48-Hour Python Exam Prep Plan – Ninja Mode 🥷🚀\n\n"
	plan_text += "🕒 T-48 to T-36 Hours: Foundation & Concepts (12 hours total)\n"
	plan_text += "• 1st Hour: Skim through all notes, slides, and past assignments—get a big-picture understanding.\n"
	plan_text += "• Next 5 Hours: Revise core concepts (data types, loops, functions, OOP, error handling).\n"
	plan_text += "• Next 6 Hours: Focus on Big O Notation, recursion, and algorithm efficiency—understand why things work, not just how.\n"
	plan_text += "• 🔥 Ninja Tip: Summarize key ideas in your own words—explain to an imaginary student.\n\n"
	
	plan_text += "🕒 T-36 to T-24 Hours: Problem-Solving & Debugging (12 hours total)\n"
	plan_text += "• First 6 Hours: Solve past exam questions timed, focusing on data structures (lists, dicts, sets), algorithms (sorting, searching), and tricky function-related problems.\n"
	plan_text += "• Next 3 Hours: Debug and analyze mistakes—learn why errors happened.\n"
	plan_text += "• Final 3 Hours: Speed drills! Solve small but varied problems quickly.\n"
	plan_text += "• 🔥 Ninja Tip: Teach a friend or record yourself explaining solutions—it reinforces memory.\n\n"
	
	plan_text += "🕒 T-24 to T-12 Hours: Advanced Topics & Edge Cases (12 hours total)\n"
	plan_text += "• 6 Hours: Tackle complex problems (recursion, file handling, multi-threading if relevant).\n"
	plan_text += "• 3 Hours: Practice writing clean, efficient code—pretend you're coding in an interview.\n"
	plan_text += "• 3 Hours: Review common pitfalls and tricky syntax issues.\n"
	plan_text += "• 🔥 Ninja Tip: Write & run mini-experiments to test edge cases.\n\n"

	plan_text += "🕒 T-12 to T-0 Hours: Review & Rest (12 hours total)\n"
	plan_text += "• 6 Hours: Quick review of key formulas, patterns, and common mistakes.\n"
	plan_text += "• 3 Hours: Restorative sleep. NO new topics—your brain needs processing time.\n"
	plan_text += "• 3 Hours before exam: Light revision, deep breaths, and confidence mode ON.\n"
	plan_text += "• 🔥 Ninja Tip: Walk in like you own the test—calm mind, steady hands, sharp code. 🥷🔥\n\n"

	plan_text += "🚀 You got this! Code like a ninja, think like a strategist.\n\n"
	plan_text += "✨ (Type your next question or command...)"
	
	display_text_with_typing_effect(plan_text)
	
	# Switch to speaking animation
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# Set study start time
	study_time_start = Time.get_unix_time_from_system()
	
	# Delay before returning to conversation mode
	await get_tree().create_timer(7.0).timeout
	change_animation(AnimState.IDLE)
	show_user_input()

# Show practice test
func show_practice_test():
	is_showing_music = false
	user_input_mode = false
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Play thinking animation
	change_animation(AnimState.THINKING)
	
	# Display introduction text
	$CanvasLayer/DialogPanel.visible = true
	display_text_with_typing_effect("🧪 Let's test your knowledge to identify areas we need to focus on...")
	
	# Wait for typing effect to complete
	await get_tree().create_timer(2.0).timeout
	
	# Build test questions
	var test_text = "📝 Quick Test - Algorithm Fundamentals:\n\n"
	test_text += "1️⃣ Which of the following variable declarations is invalid?\n"
	test_text += "   a) my_var = 10\n"
	test_text += "   b) 2nd_number = 5\n"
	test_text += "   c) _count = 7\n\n"
	
	test_text += "2️⃣ Which of the following is a correct way to define a Python function?\n"
	test_text += "   a) def add(x, y): return x + y\n"
	test_text += "   b) function add(x, y): return x + y\n"
	test_text += "   c) define add(x, y) { return x + y }\n\n"
	
	test_text += "3️⃣ Which of the following is a correct way to define a Python class?\n"
	test_text += "   a) class Car: pass\n"
	test_text += "   b) class Car(object): pass\n"
	test_text += "   c) All of the above\n\n"
	
	test_text += "✍️ Type your answers as '1b 2a 3c' format."
	
	# Switch to speaking animation
	change_animation(AnimState.TALKING)
	display_text_with_typing_effect(test_text)
	
	# Wait for typing effect to complete
	await get_tree().create_timer(3.0).timeout
	
	# Show input container, but keep test text
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# Set user input mode
	user_input_mode = true

# Show health tip
func show_health_tip():
	is_showing_music = false
	user_input_mode = false
	
	# Play happy animation
	change_animation(AnimState.HAPPY)
	
	# Display health tip
	$CanvasLayer/DialogPanel.visible = true
	
	# Randomly select a health tip
	var tip = health_reminders[randi() % health_reminders.size()]
	display_text_with_typing_effect(tip + "\n\n(Type your next question or command...)")
	
	# Switch to speaking animation
	await get_tree().create_timer(1.5).timeout
	change_animation(AnimState.TALKING)
	
	# Delay before returning to conversation mode
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	show_user_input()

# Show health reminder popup
func show_health_reminder():
	# Only show health reminder if no other content is being displayed
	if not is_typing_text and not is_showing_music and not user_input_mode:
		# Show health tip
		show_health_tip()

# Process test answers
func process_test_answer(answer):
	var correct_answers = "1b 2c 3b"
	var score = 0
	
	# Simple comparison of answers
	var user_answers = answer.to_lower().strip_edges()
	var answers_array = user_answers.split(" ")
	var correct_array = correct_answers.split(" ")
	
	for i in range(min(answers_array.size(), correct_array.size())):
		if answers_array[i] == correct_array[i]:
			score += 1
	
	# Display result
	var result_text = "You scored " + str(score) + " out of 3.\n\n"
	
	if score == 3:
		result_text += "Excellent! You're well prepared for the algorithms section!"
		change_animation(AnimState.HAPPY)
	elif score == 2:
		result_text += "Good job! But let's review the question you missed."
		change_animation(AnimState.TALKING)
	else:
		result_text += "We've identified some areas to work on. Let's focus on these topics!"
		change_animation(AnimState.THINKING)
	
	# Display correct answers
	result_text += "\n\nCorrect answers:\n"
	result_text += "1. b) O(n²)\n"
	result_text += "2. c) Optimal substructure\n"
	result_text += "3. b) Heap\n\n"
	
	result_text += "(Type your next question or command...)"
	
	display_text_with_typing_effect(result_text)
	
	# Delay before continuing
	await get_tree().create_timer(3.0).timeout
	
	# Show input container, but keep test result text
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# Set user input mode
	user_input_mode = true
	
	# Delay before returning to conversation mode
	await get_tree().create_timer(0.5).timeout
	show_user_input()

# Trigger when clicking on the pet
func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("ClickArea signal triggered: Ninja cat clicked!")
		show_next_dialogue()
		return

# Handle user input text box submission
func _on_input_box_text_submitted(new_text):
	_on_send_button_pressed()  # Reuse button processing logic

# Handle user input messages
func process_user_input(message):
	# Record user question to conversation history
	conversation_history.append({"role": "user", "content": message})
	
	# Check if it's a test answer
	if is_showing_music:
		return
	
	# Save current displayed text to maintain continuity of conversation
	var current_text = current_display_text
	
	# If current text already contains "User:", we need to add it to the existing conversation
	# Otherwise, just display the user question
	if "User:" in current_text:
		display_text_with_typing_effect(current_text + "\n\nUser: " + message)
	else:
		display_text_with_typing_effect("User: " + message)
	
	# Switch to speaking animation to indicate receiving a question
	change_animation(AnimState.TALKING)
	
	# Wait for a short time
	await get_tree().create_timer(1.0).timeout
	
	# Display AI thinking process
	show_ai_thinking_process(message)

# Display AI thinking process
func show_ai_thinking_process(message):
	# Switch to thinking animation
	change_animation(AnimState.THINKING)
	
	# Randomly select three thinking phrases to display
	var selected_phrases = []
	var available_phrases = thinking_phrases.duplicate()
	for i in range(min(3, thinking_phrases.size())):
		var index = randi() % available_phrases.size()
		selected_phrases.append(available_phrases[index])
		available_phrases.remove_at(index)
	
	# Save current displayed text to maintain continuity of conversation
	var current_text = current_display_text
	
	# Display thinking process, keeping user question visible
	for phrase in selected_phrases:
		var thinking_text = current_text
		if not thinking_text.ends_with("\n\n"):
			thinking_text += "\n\n"
		thinking_text += phrase
		display_text_with_typing_effect(thinking_text)
		await get_tree().create_timer(0.8).timeout
	
	# Call Gemini API to get a response
	call_gemini_api(message)

# Call Gemini API
func call_gemini_api(message):
	# Check API key
	if api_key.strip_edges().is_empty():
		print("API key is empty, using fallback response")
		use_fallback_response(message)
		return
	
	# Add API test check
	print("Testing API access with key: " + api_key.substr(0, 5) + "...")

	# Create HTTP request
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_gemini_response_received)
	
	# Build request URL (including API key)
	var url = GEMINI_API_URL + "?key=" + api_key
	
	# Prepare request headers
	var headers = ["Content-Type: application/json"]
	
	# Enhance prompt to make response more like Final Ninja
	var system_prompt = "You are Final Ninja, a quirky pixel-art ninja character who helps students prepare for exams. Your mission is to help defeat the 'Final Monster' (exam stress) with efficient study strategies. Be encouraging, slightly humorous, and give concise, practical advice. Keep responses under 3 paragraphs. Focus on effective study techniques, time management, and mental well-being."
	
	# Build request body
	var body = {
		"contents": [
			{
				"role": "user",
				"parts": [
					{"text": system_prompt},
					{"text": "Student question: " + message}
				]
			}
		],
		"generationConfig": {
			"temperature": 0.7,
			"topP": 0.8,
			"topK": 40,
			"maxOutputTokens": 1000
		}
	}
	
	# Add debug information
	print("Sending API request to: " + GEMINI_API_URL)
	print("Request body: " + JSON.stringify(body))
	
	# Send request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		print("Error making HTTP request: ", error)
		# Show danger animation if there's an error
		change_animation(AnimState.DANGER)
		await get_tree().create_timer(1.0).timeout
		use_fallback_response("")

# Handle Gemini API response
func _on_gemini_response_received(result, response_code, headers, body):
	var response_node = get_node_or_null("HTTPRequest")
	if response_node:
		response_node.queue_free()
	
	print("API Response Code: ", response_code)
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("Error in API response: ", response_code)
		# Print response body for diagnostic purposes
		print("Response body: ", body.get_string_from_utf8())
		# Show danger animation if there's an error
		change_animation(AnimState.DANGER)
		await get_tree().create_timer(1.0).timeout
		use_fallback_response("")
		return
	
	# Parse response
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("JSON Parse Error: ", parse_result)
		print("Response body: ", body.get_string_from_utf8())
		use_fallback_response("")
		return
	
	var response_data = json.get_data()
	print("Received valid response: ", JSON.stringify(response_data))
	
	# Extract text from response (based on Gemini API response structure)
	var ai_message = ""
	if response_data.has("candidates") and response_data["candidates"].size() > 0:
		if response_data["candidates"][0].has("content") and response_data["candidates"][0]["content"].has("parts"):
			var parts = response_data["candidates"][0]["content"]["parts"]
			if parts.size() > 0 and parts[0].has("text"):
				ai_message = parts[0]["text"]
	
	if ai_message.strip_edges().is_empty():
		print("Empty response received, using fallback")
		use_fallback_response("")
		return
	
	# Get last user message
	var last_user_message = ""
	if conversation_history.size() > 0:
		last_user_message = conversation_history[conversation_history.size() - 1].content
	
	# Add API response to conversation history
	conversation_history.append({"role": "assistant", "content": ai_message})
	
	# Switch to happy animation
	change_animation(AnimState.HAPPY)
	
	# Display response text - show both user question and AI answer
	var display_text = ""
	if not last_user_message.is_empty():
		display_text = "User: " + last_user_message + "\n\n"
	
	display_text += "Final Ninja: " + ai_message + "\n\n(Type your next question or command...)"
	display_text_with_typing_effect(display_text)
	
	# Switch to speaking animation
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# Delay before returning to conversation mode
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	
	# Show user input interface
	show_user_input()

# Use fallback response
func use_fallback_response(message):
	print("Using fallback response")
	
	# Random fallback reply
	var fallback_replies = [
		"I seem to be having trouble connecting to my knowledge base. Could you try asking me in a different way?",
		"Hmm, my ninja senses are temporarily blocked. Let's try a different question!",
		"Even ninjas face challenges! I couldn't process that request. Could you rephrase it?",
		"My apologies, I'm having trouble formulating a response. Let's try another topic!"
	]
	
	var fallback_message = fallback_replies[randi() % fallback_replies.size()]
	
	# Get last user message
	var last_user_message = ""
	if message.strip_edges().is_empty() and conversation_history.size() > 0:
		last_user_message = conversation_history[conversation_history.size() - 1].content
	else:
		last_user_message = message
	
	# Add fallback reply to conversation history
	conversation_history.append({"role": "assistant", "content": fallback_message})
	
	# Switch to speaking animation
	change_animation(AnimState.TALKING)
	
	# Display response text - show both user question and fallback answer
	var display_text = ""
	if not last_user_message.is_empty():
		display_text = "User: " + last_user_message + "\n\n"
	
	display_text += "Final Ninja: " + fallback_message + "\n\n(Type your next question or command...)"
	display_text_with_typing_effect(display_text)
	
	# Delay before returning to conversation mode
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	
	# Show user input interface
	show_user_input()

# New function: Use rich text to display text with links
func display_text_with_rich_text(text):
	# Stop current typing effect
	is_typing_text = false
	
	# Get dialog label
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	
	# If current label is not RichTextLabel or invalid, create a new one
	if not dialog_label is RichTextLabel or not is_instance_valid(dialog_label):
		# Delete old label (if exists)
		if dialog_label and is_instance_valid(dialog_label):
			# Save current label attributes
			var current_pos = dialog_label.position
			var current_size = dialog_label.size
			var current_font_size = dialog_label.get_theme_font_size("font_size")
			dialog_label.queue_free()
			
			# Wait for a frame to ensure deletion is complete
			await get_tree().process_frame
			
			# Create RichTextLabel
			var rich_text = RichTextLabel.new()
			rich_text.name = "DialogLabel"
			rich_text.position = current_pos
			rich_text.size = current_size
			rich_text.bbcode_enabled = true
			rich_text.meta_underlined = true
			rich_text.add_theme_font_size_override("normal_font_size", current_font_size)
			rich_text.add_theme_font_size_override("bold_font_size", current_font_size + 2)
			rich_text.add_theme_font_size_override("italics_font_size", current_font_size)
			rich_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			
			# Set link color and label style
			rich_text.add_theme_color_override("default_color", Color(1, 1, 1)) # Main text white
			rich_text.add_theme_color_override("font_selected_color", Color(0.8, 0.8, 0.8))
			rich_text.add_theme_constant_override("line_separation", 8) # Increase line spacing to prevent overlap
			
			# Connect link click signal
			rich_text.connect("meta_clicked", _on_link_clicked)
			rich_text.connect("meta_hover_started", _on_link_hover_started)
			rich_text.connect("meta_hover_ended", _on_link_hover_ended)
			
			# Add to dialog panel
			$CanvasLayer/DialogPanel.add_child(rich_text)
			dialog_label = rich_text
		else:
			# If no label exists, create a new one
			var rich_text = RichTextLabel.new()
			rich_text.name = "DialogLabel"
			rich_text.position = Vector2(10, 10) # Update position to 10,10
			rich_text.size = Vector2(610, 350) # Update size to new set dimensions
			rich_text.bbcode_enabled = true
			rich_text.meta_underlined = true
			rich_text.add_theme_font_size_override("normal_font_size", 24) # Update to 24 font size
			rich_text.add_theme_font_size_override("bold_font_size", 26) # Bold text slightly larger
			rich_text.add_theme_font_size_override("italics_font_size", 24) # Italic text size
			rich_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			
			# Set link color and label style
			rich_text.add_theme_color_override("default_color", Color(1, 1, 1)) # Main text white
			rich_text.add_theme_constant_override("line_separation", 8) # Increase line spacing to prevent overlap
			
			# Connect link click signal
			rich_text.connect("meta_clicked", _on_link_clicked)
			rich_text.connect("meta_hover_started", _on_link_hover_started)
			rich_text.connect("meta_hover_ended", _on_link_hover_ended)
			
			# Add to dialog panel
			$CanvasLayer/DialogPanel.add_child(rich_text)
			dialog_label = rich_text
	
	# Ensure label exists
	if dialog_label and is_instance_valid(dialog_label):
		# Force clear all content
		dialog_label.clear()
		dialog_label.text = ""
		
		# Wait for a frame to ensure clearing is complete
		await get_tree().process_frame
		
		# Set rich text content
		dialog_label.clear()
		dialog_label.append_text(text)
		
		# Update current displayed text
		current_display_text = text
		full_text_to_display = text
	else:
		print("ERROR: Dialog label is null or invalid in display_text_with_rich_text")

# Handle link clicks
func _on_link_clicked(meta):
	print("Link clicked: ", meta)
	
	# Handle internal navigation links
	if meta == "option_1":
		show_music_playlists()
		return
	elif meta == "option_2":
		show_custom_playlist_interface()
		return
	elif meta == "option_3" or meta == "back" or meta == "music_menu":
		if meta == "music_menu":
			show_music_options()
		else:
			is_showing_music = false
			show_user_input()
		return
	elif meta == "adhd_url" or meta == "adhd_font" or meta == "adhd_focus":
		# Show information about feature under development
		var adhd_info = "This feature is currently in development...\n\n"
		adhd_info += "[url=adhd][color=#3498db]🔙 Back to ADHD Reader Mode[/color][/url]"
		display_text_with_rich_text(adhd_info)
		return
	elif meta == "adhd":
		show_adhd_reader_mode()
		return
	
	# Handle external links (Spotify URLs)
	OS.shell_open(str(meta))

# Add link hover effect handling function
func _on_link_hover_started(meta):
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label) and dialog_label is RichTextLabel:
		# Add hover effect - play small animation or sound
		$CanvasLayer/DialogPanel/DialogLabel.add_theme_constant_override("outline_size", 1)
		# You can add more hover effects here, like playing sound
		# $AudioHover.play()

func _on_link_hover_ended(meta):
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label) and dialog_label is RichTextLabel:
		# Return to normal state
		$CanvasLayer/DialogPanel/DialogLabel.add_theme_constant_override("outline_size", 0)

# Show ADHD reading mode
func show_adhd_reader_mode():
	is_showing_music = false
	user_input_mode = false
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# Display loading message, giving UI time to update
	display_text_with_typing_effect("📱 Loading ADHD Reader Mode...")
	
	# Play happy animation
	change_animation(AnimState.HAPPY)
	
	# Wait for a short time to ensure UI updates
	await get_tree().create_timer(0.5).timeout
	
	# Create modern menu, avoiding overlap and encoding issues
	var menu_text = "[center][color=#3498db][font_size=22]🧠 ADHD Reader Mode[/font_size][/color][/center]\n\n"
	
	menu_text += "[color=#e74c3c]1.[/color] [url=adhd_url][color=#f1c40f]🔗 Open URL[/color][/url]\n"
	menu_text += "   Open webpage with ADHD-friendly display\n\n"
	
	menu_text += "[color=#e74c3c]2.[/color] [url=adhd_font][color=#f1c40f]🔤 Change Font Style[/color][/url]\n"
	menu_text += "   Adjust font to enhance readability\n\n"
	
	menu_text += "[color=#e74c3c]3.[/color] [url=adhd_focus][color=#f1c40f]👁️ Enable Focus Mode[/color][/url]\n"
	menu_text += "   Reduce distracting elements and enhance focus\n\n"
	
	menu_text += "[color=#e74c3c]4.[/color] [url=back][color=#f1c40f]🏠 Return to Main Menu[/color][/url]\n"
	menu_text += "   Go back to main options\n\n"
	
	menu_text += "[color=#7f8c8d]Click any option or type option number[/color]"
	
	# Completely clear and redisplay
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # Ensure first empty
	
	# Display introduction text with menu
	display_text_with_rich_text("📱 ADHD Reader Mode can help you read and focus more easily!\n\n" + menu_text)
	
	# Switch to speaking animation
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# Show input container
	await get_tree().create_timer(0.5).timeout
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# Set user input mode
	user_input_mode = true

# Show rankings
func show_ninja_ranking():
	is_showing_music = false
	user_input_mode = false
	
	# Show dialog box
	$CanvasLayer/DialogPanel.visible = true
	
	# First clear any existing text being displayed
	current_display_text = ""
	full_text_to_display = ""
	
	# Display loading message
	display_text_with_typing_effect("🥷 Loading Ninja Community Rankings...")
	
	# Play thinking animation
	change_animation(AnimState.THINKING)
	
	# Wait for a short time to ensure UI updates
	await get_tree().create_timer(1.0).timeout
	
	# Create ranking content
	var rankings_text = "🏆 Ninja Community Rankings\n\n"
	rankings_text += "1. 🐯 Tiger Ninja - Level 12\n"
	rankings_text += "   Study Time: 51 hours | Status: Ultimate Focus\n\n"
	
	rankings_text += "2. 😺 Hello Kitty Ninja - Level 11\n"
	rankings_text += "   Study Time: 53 hours | Status: Cute Concentration\n\n"
	
	rankings_text += "3. 🦊 Fox Ninja - Level 10\n"
	rankings_text += "   Study Time: 47 hours | Status: Deep Learning\n\n"
	
	rankings_text += "4. 🐰 Bunny Ninja - Level 9\n"
	rankings_text += "   Study Time: 44 hours | Status: Quick Learner\n\n"
	
	rankings_text += "5. 🥷 Final Ninja (You) - Level 9\n"
	rankings_text += "   Study Time: 42 hours | Status: Master Focus\n\n"
	
	rankings_text += "6. 🐼 Panda Ninja - Level 8\n"
	rankings_text += "   Study Time: 38 hours | Status: Bamboo Scholar\n\n"
	
	rankings_text += "7. 🐹 Quokka Ninja - Level 8\n"
	rankings_text += "   Study Time: 36 hours | Status: Happy Studying\n\n"
	
	rankings_text += "8. 🦝 Wombat Ninja - Level 7\n"
	rankings_text += "   Study Time: 33 hours | Status: Night Explorer\n\n"
	
	rankings_text += "Keep studying to increase your level and reach the top of the rankings!\n\n"
	rankings_text += "(Type 'back' to return to main menu)"
	
	# Display ranking text
	display_text_with_typing_effect(rankings_text)
	
	# Switch to speaking animation
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# Delay before returning to idle state
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	
	# Show input container
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# Clear and focus input box
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# Set user input mode
	user_input_mode = true

var dragging = false
var drag_start_position = Vector2()
var window_start_position = Vector2i()

func _input(event):
	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		var window = get_window()
		var current_position = window.position
		var new_position = current_position
		
		# Detect direction key input
		match event.keycode:
			KEY_UP:
				new_position.y -= window_move_speed # Move up
			KEY_DOWN:
				new_position.y += window_move_speed # Move down
			KEY_LEFT:
				new_position.x -= window_move_speed # Move left
			KEY_RIGHT:
				new_position.x += window_move_speed # Move right
		
		# Apply new position
		if new_position != current_position:
			window.position = new_position
	
	# Handle mouse click events
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if click position is on the sprite
		var sprite = $Sprite2D
		var sprite_pos = sprite.global_position
		var sprite_size = sprite.texture.get_size() * sprite.scale
		var mouse_pos = event.position
		
		var left = sprite_pos.x - sprite_size.x/2
		var right = sprite_pos.x + sprite_size.x/2
		var top = sprite_pos.y - sprite_size.y/2
		var bottom = sprite_pos.y + sprite_size.y/2
		
		# Show dialogue when ninja cat is clicked
		if mouse_pos.x > left and mouse_pos.x < right and mouse_pos.y > top and mouse_pos.y < bottom:
			print("Click detected on ninja sprite")
			show_next_dialogue()
			return
		
		# Check if click is on the dialog box
		var dialog_panel = $CanvasLayer/DialogPanel
		if dialog_panel and dialog_panel.visible:
			var dialog_rect = Rect2(dialog_panel.global_position, dialog_panel.size)
			
			# If click is on the dialog box (excluding input box area)
			if dialog_rect.has_point(mouse_pos):
				var input_container = $CanvasLayer/DialogPanel/InputContainer
				var input_rect = Rect2()
				
				# Check if click is in input box area
				if input_container and input_container.visible:
					input_rect = Rect2(input_container.global_position, input_container.size)
				
				# If click is not in input box area, trigger dialogue continuation
				if not input_rect.has_point(mouse_pos) and not is_typing_text:
					print("Click detected on dialog panel")
					if user_input_mode:
						# If in user input mode, clicking the dialog box has no effect
						pass
					else:
						# If not in typing effect, continue to next dialogue or show input interface
						show_next_dialogue()
						return
