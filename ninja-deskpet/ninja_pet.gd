extends Node2D

# Gemini API配置
const GEMINI_API_URL = "<Your Gemini API URL>" # 需要设置你的Gemini API URL
var api_key = "<Your Gemini API Key>" # 需要设置你的Gemini API密钥

# 在变量声明部分添加
var countdown_bar: ProgressBar
var max_time: float = 1800.0  # 30分钟的倒计时
var current_time: float = 1800.0

# 在文件开头的变量声明部分添加
var countdown_label: Label

# 智能音乐服务URL
const CHATJAMS_URL = "https://www.chatjams.ai/playlist/"

# 预设的对话内容(英文)
var dialogues = [
	"👋 Hi, I'm Final Ninja! My mission is to help people pass the final week.",
	"📚 I noticed you're struggling with your exams. Don't worry, I'm here to help!",
	"⏱️ We have 48 hours to prepare efficiently for your finals.",
	"💪 But we need to defeat the Final Monster together to succeed!",
	"🤔 What can I help you with? (Type 'plan' for AI genrated study plan, 'quiz' for testing your knowledge, 'music' for generated playlist, 'adhd' for ADHD Reader Mode, or 'ranking' to check your ranking at ninja community)"
]

# AI风格的思考短语
var thinking_phrases = [
	"🧠 Analyzing your learning patterns...",
	"🔍 Identifying knowledge gaps...",
	"✨ Crafting the optimal strategy...",
	"🔢 Calculating the most efficient approach...",
	"🎯 Preparing personalized recommendations..."
]

# 学习计划相关提示
var study_plan_dialogue = [
	"📅 Let's create a 48-hour study plan to conquer your finals!",
	"🧩 Based on your learning style, I recommend focusing on difficult topics first.",
	"🏆 We'll tackle the hardest parts, then consolidate, and finally do practice tests.",
	"⚡ Remember: strategic breaks are crucial for optimal learning!"
]

# 音乐关键词和描述
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

# 音乐歌单列表
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

# 健康提醒消息
var health_reminders = [
	"⏰ You've been studying for 2 hours straight! Time for a 5-minute break.",
	"💧 Remember to stay hydrated! Grab some water and stretch a bit.",
	"👁️ Your eyes need rest - look at something 20 feet away for 20 seconds.",
	"🚶 Stand up and move around for a few minutes to boost your circulation!",
	"🧠 Mental fatigue detected! A 10-minute break now will improve your productivity."
]

var current_dialogue_index = 0  # 当前对话索引
var user_input_mode = false  # 是否处于用户输入模式
var conversation_history = []  # 对话历史记录
var is_showing_music = false   # 是否正在显示音乐功能
var is_typing_text = false     # 是否正在执行打字效果
var typing_speed = 0.02        # 打字速度 (秒/字符)
var current_display_text = ""  # 当前显示文本
var full_text_to_display = ""  # 要显示的完整文本
var typing_timer = 0.0         # 打字计时器
var custom_playlist_mode = false # 是否处于自定义播放列表模式
var study_time_start = 0       # 学习开始时间
var health_reminder_timer = 0  # 健康提醒计时器
var music_option_selection_pending = false # 是否正在等待音乐选项选择

# 动画状态 - 基于已有动画资源
enum AnimState {IDLE, TALKING, THINKING, HAPPY, DANGER}
var current_anim_state = AnimState.IDLE

# 增加窗口移动速度变量
var window_move_speed = 40 # 从30增加到40，每次按键移动的像素数

# 添加模拟排名数据
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

# 初始化
func _ready():
	print("Initialization started...")
	
	# 设置透明背景 - 更全面的设置
	get_window().transparent_bg = true
	
	# 设置清除颜色为完全透明
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 0))
	
	# 确保场景背景为透明
	var root_viewport = get_tree().root
	root_viewport.transparent_bg = true
	
	# 初始化对话框
	var dialog_panel = $CanvasLayer/DialogPanel
	dialog_panel.visible = false
	
	# 设置对话框样式 - 增加大小以适应内容
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	dialog_label.size = Vector2(700, 800) # 增加宽度和高度以更好地填满panel
	dialog_label.position = Vector2(10, 10) # 减少边距
	dialog_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_label.add_theme_font_size_override("font_size", 40) # 增加默认字体大小
	
	# 创建面板的样式并设置透明背景
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(1, 1, 1, 0.5)  # 白色半透明背景
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1, 1, 1, 0.9)  # 边框颜色为白色
	panel_style.shadow_color = Color(0, 0, 0, 0.5)  # 阴影颜色
	panel_style.shadow_size = 15
	panel_style.shadow_offset = Vector2(0, 4)

	# 将自定义样式应用到对话框面板
	dialog_panel.add_theme_stylebox_override("panel", panel_style)
	# 可选：调整透明度增强毛玻璃效果
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)  # 设置半透明背景
	dialog_panel.add_theme_stylebox_override("panel", panel_style)
	# 可选：使用模糊背景图片作为背景（如果需要更强的毛玻璃效果）
	#var background = TextureRect.new()
	#background.texture = load("Users/mustang/Downloads/cybercity.jpeg")  # 模糊背景图
	#background.expand = true  # 拉伸填充背景
	#dialog_panel.add_child(background)  # 将背景添加到对话框中

	# 初始化倒计时进度条
	countdown_bar = $CanvasLayer/DialogPanel/ProgressBar
	countdown_label = $CanvasLayer/DialogPanel/CountdownLabel
	if countdown_bar:
		countdown_bar.max_value = max_time
		countdown_bar.value = current_time
		countdown_bar.show_percentage = false  # 禁用百分比显示
		
		# 设置进度条样式
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # 背景颜色
		style.set_corner_radius_all(8)  # 圆角
		countdown_bar.add_theme_stylebox_override("background", style)
		
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color(0.3, 0.8, 0.3, 1.0)  # 填充颜色
		fill_style.set_corner_radius_all(8)  # 圆角
		countdown_bar.add_theme_stylebox_override("fill", fill_style)
	
	if countdown_label:
		countdown_label.add_theme_font_size_override("font_size", 28)
		countdown_label.add_theme_color_override("font_color", Color(1, 1, 1))
	
	# 初始化用户输入框样式
	var input_box = $CanvasLayer/DialogPanel/InputContainer
	input_box.visible = false
	
	# 为输入框添加现代样式
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
		
		# 设置输入框文字颜色和字体大小
		input_field.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		input_field.add_theme_font_size_override("font_size", 20) # 增加输入框字体大小
	
	# 预加载所有动画
	preload_animations()
	
	# 启动动画
	change_animation(AnimState.IDLE)
	print("Initialization completed")
	
	# 开始AI启动序列
	await get_tree().create_timer(0.5).timeout
	show_next_dialogue()
	
# 预加载动画以确保平滑播放
func preload_animations():
	# 确保所有动画都在AnimationPlayer中创建
	# 这里只是检查是否存在，实际创建应在编辑器中完成
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
	
# 添加 _input 函数作为备用的点击检测方法


func _process(delta):
	# 更新倒计时
	if countdown_bar and current_time > 0:
		current_time -= delta / 1  # 转换为秒
		countdown_bar.value = current_time
		
		# 更新进度条颜色
		if current_time <= 300:  # 小于等于5分钟 (300秒)
			var fill_style = StyleBoxFlat.new()
			fill_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # 红色
			fill_style.set_corner_radius_all(8)  # 保持圆角
			countdown_bar.add_theme_stylebox_override("fill", fill_style)
		
		# 更新显示文本
		if countdown_label:
			var minutes = int(current_time) / 60
			var seconds = int(current_time) % 60
			countdown_label.text = "%d:%02d" % [minutes, seconds]

	# 确保背景始终保持透明
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 0))
	
	# 确保动画一直播放
	if not $AnimationPlayer.is_playing():
		match current_anim_state:
			AnimState.IDLE:
				$AnimationPlayer.play("idle")
			AnimState.TALKING:
				$AnimationPlayer.play("talking")  # 使用talking动画表示说话
			AnimState.THINKING:
				$AnimationPlayer.play("thinking")  # 使用thinking动画表示思考
			AnimState.HAPPY:
				$AnimationPlayer.play("happy")  # 使用happy动画表示高兴
			AnimState.DANGER:
				$AnimationPlayer.play("danger")  # 使用danger动画表示危险情况
	
	# 处理打字效果
	if is_typing_text:
		typing_timer += delta
		if typing_timer >= typing_speed:
			typing_timer = 0.0
			if current_display_text.length() < full_text_to_display.length():
				current_display_text += full_text_to_display[current_display_text.length()]
				# 添加空值检查
				var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
				if dialog_label and is_instance_valid(dialog_label):
					dialog_label.text = current_display_text
			else:
				is_typing_text = false
	
	# 处理健康提醒
	if study_time_start > 0:
		health_reminder_timer += delta
		# 每30分钟(1800秒)提醒一次
		if health_reminder_timer >= 1800:
			health_reminder_timer = 0
			show_health_reminder()

# 改变动画状态
func change_animation(new_state):
	current_anim_state = new_state
	
	match new_state:
		AnimState.IDLE:
			$AnimationPlayer.play("idle")
		AnimState.TALKING:
			$AnimationPlayer.play("talking")  # 使用talking动画表示说话
		AnimState.THINKING:
			$AnimationPlayer.play("thinking")  # 使用thinking动画表示思考
		AnimState.HAPPY:
			$AnimationPlayer.play("happy")  # 使用happy动画表示高兴
		AnimState.DANGER:
			$AnimationPlayer.play("danger")  # 使用danger动画表示危险情况

# 显示带有打字效果的文本
func display_text_with_typing_effect(text):
	is_typing_text = true
	current_display_text = ""
	full_text_to_display = text
	typing_timer = 0.0
	
	# 确保DialogLabel存在并且字体大小正确
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		if not dialog_label is RichTextLabel:
			dialog_label.add_theme_font_size_override("font_size", 24) # 确保使用新的字体大小

# 显示下一句对话
func show_next_dialogue():
	print("Showing dialogue: ", current_dialogue_index)
	if user_input_mode or is_showing_music or is_typing_text:
		return
		
	if current_dialogue_index < dialogues.size():
		# 显示对话框
		$CanvasLayer/DialogPanel.visible = true
		
		# 更新对话内容 - 使用打字效果
		display_text_with_typing_effect(dialogues[current_dialogue_index])
		current_dialogue_index += 1
		
		# 切换到说话动画
		change_animation(AnimState.TALKING)
		
		# 一段时间后回到空闲状态
		await get_tree().create_timer(2.5).timeout
		change_animation(AnimState.IDLE)
	else:
		# 对话结束后，显示用户输入界面
		show_user_input()

# 显示用户输入界面
func show_user_input():
	user_input_mode = true
	custom_playlist_mode = false
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 如果是focus jazz模式，显示特殊文本
	var user_input = $CanvasLayer/DialogPanel/InputContainer/InputBox
	if user_input.text == "focus jazz" || user_input.text == "ninja vibe":
		display_text_with_typing_effect("Creating a '" + user_input.text + "' playlist for you!.")
		# 切换到说话动画
		change_animation(AnimState.TALKING)
		await get_tree().create_timer(2.0).timeout
		# 直接调用音乐生成功能
		generate_custom_playlist(user_input.text)
		return
	# 如果是首次显示用户输入界面，则显示完整的对话内容
	elif current_dialogue_index == dialogues.size() and current_display_text.strip_edges().is_empty():
		# 获取最后一条对话内容
		var last_dialogue = dialogues[dialogues.size() - 1]
		# 添加输入提示
		var prompt_text = last_dialogue + "\n\n(✍️ Please type your question or command...)"
		display_text_with_typing_effect(prompt_text)
	else:
		# 如果已经有对话内容在显示，则检查是否已包含输入提示
		if not is_typing_text and current_display_text.length() > 0:
			var current_text = current_display_text
			# 检查是否已经有输入提示
			if not "(Type " in current_text and not "(Please type" in current_text and not "(✍️" in current_text:
				current_text += "\n\n(✍️ Type your next question or command...)"
				display_text_with_typing_effect(current_text)
		elif current_display_text.strip_edges().is_empty():
			# 如果没有显示任何内容，则显示一个基本提示
			display_text_with_typing_effect("🤔 What can I help you with? (Type 'plan' for study plan, 'test' for practice, or 'music' for focus music)")
	
	# 等待打字效果完成
	await get_tree().create_timer(1.0).timeout
	
	# 显示输入容器
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# 切换到空闲动画
	change_animation(AnimState.IDLE)

# 处理用户输入
func _on_send_button_pressed():
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	var user_message = input_box.text
	print(">>>> 用户当前输入：" + user_message)

	if user_message.strip_edges().length() > 0:
		# 隐藏输入框
		$CanvasLayer/DialogPanel/InputContainer.visible = false
		
		# 在处理输入前记录当前模式状态（仅用于调试）
		print("Processing user input, mode status:")
		print("- custom_playlist_mode: ", custom_playlist_mode)
		print("- is_showing_music: ", is_showing_music)
		print("- user_input_mode: ", user_input_mode)
		print("- music_option_selection_pending: ", music_option_selection_pending)
		
		# 检查通用返回命令
		var lower_message = user_message.to_lower().strip_edges()
		if lower_message == "back" or lower_message == "menu":
			print("User requested to return to main menu")
			custom_playlist_mode = false
			is_showing_music = false
			music_option_selection_pending = false
			show_user_input()
			return
		
		# 检查是否是课程选择
		if user_message.is_valid_int():
			var course_index = user_message.to_int() - 1
			if course_index >= 0 and course_index < courses.size():
				show_study_plan()  # 显示选中课程的学习计划
				return

		# 首先检查是否正在等待音乐选项选择
		if music_option_selection_pending:
			print("Processing music option selection: ", user_message)
			music_option_selection_pending = false  # 重置标志
			
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
		
		# 检查特殊命令
		elif lower_message == "ranking":
			show_ninja_ranking()
		elif lower_message == "music":
			show_music_options()
		elif lower_message == "plan":
			# 先查询课程列表
			show_course_selection()
		elif lower_message == "9136":
			# 展示课程学习summary+plan
			show_study_plan()
		elif lower_message == "quiz":
			show_practice_test()
		elif lower_message == "health":
			show_health_tip()
		elif lower_message == "adhd":
			show_adhd_reader_mode()
		elif lower_message == "1b 2a 3c":
			# 处理用户答案
			process_quiz_answer()
		else:
			# 处理一般用户输入
			process_user_input(user_message)

# 处理用户quiz答案
func process_quiz_answer():
	is_showing_music = false
	user_input_mode = false
	
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 播放思考动画
	change_animation(AnimState.THINKING)
	
	# 显示评估消息
	display_text_with_typing_effect("🤔 Evaluating your answers...")
	
	# 等待短暂时间以显示动画效果
	await get_tree().create_timer(1.5).timeout
	
	# 用户答案和正确答案
	var user_answers = "1b 2a 3c"
	var correct_answers = "1b 2a 3c"
	var score = 3  # 满分，因为答案完全匹配
	
	# 答案解释
	var explanations = {
		"1": "✅ Correct! Variable names cannot start with numbers. '2nd_number' is an invalid variable name.",
		"2": "✅ Correct! In Python, using the 'def' keyword is the correct syntax for defining functions.",
		"3": "✅ Correct! In Python, both class definition methods are valid."
	}
	
	# 构建结果文本
	var result_text = "📝 Quiz Results:\n\n"
	result_text += "🌟 Perfect! You got all questions right!\n\n"
	result_text += "Detailed Explanations:\n"
	
	# 添加每个问题的解释
	for i in range(1, 4):
		result_text += str(i) + ". " + explanations[str(i)] + "\n\n"
	
	# 添加鼓励性的反馈
	result_text += "💪 Excellent! You've mastered these fundamental concepts.\n"
	result_text += "Ready for the next challenge?\n\n"
	result_text += "✍️ Type your next question or command..."
	
	# 切换到开心动画
	change_animation(AnimState.HAPPY)
	
	# 显示结果
	display_text_with_typing_effect(result_text)
	
	# 延迟后显示输入界面
	await get_tree().create_timer(2.0).timeout
	show_user_input()

# 显示音乐选项
func show_music_options():
	is_showing_music = true
	user_input_mode = false
	custom_playlist_mode = false  # 确保开始时重置此模式
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 显示加载中提示，给UI更新提供时间
	display_text_with_typing_effect("🎵 Loading music options...")
	
	# 播放开心动画
	change_animation(AnimState.HAPPY)
	
	# 等待短暂时间以确保UI更新
	await get_tree().create_timer(0.5).timeout
	
	# 创建更简洁的现代菜单，避免重叠和乱码问题
	var menu_text = "[center][color=#3498db][font_size=22]🎧 Music Options[/font_size][/color][/center]\n\n"
	
	menu_text += "[color=#e74c3c]1.[/color] [url=option_1][color=#f1c40f]🎶 Browse Spotify Playlists[/color][/url]\n"
	menu_text += "   Discover curated playlists for studying\n\n"
	
	menu_text += "[color=#e74c3c]2.[/color] [url=option_2][color=#f1c40f]✨ Generate Custom Playlist[/color][/url]\n"
	menu_text += "   Create a playlist based on your mood\n\n"
	
	menu_text += "[color=#e74c3c]3.[/color] [url=option_3][color=#f1c40f]🏠 Return to Main Menu[/color][/url]\n"
	menu_text += "   Go back to the main options\n\n"
	
	menu_text += "[color=#7f8c8d]Click any option or type 1, 2, or 3[/color]"
	
	# 完全清除并重新显示
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # 确保先清空
	
	# 显示介绍文本加菜单
	display_text_with_rich_text("🎵 I can help you find some music to enhance your study session!\n\n" + menu_text)
	
	# 切换到说话动画
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# 显示输入容器
	await get_tree().create_timer(0.5).timeout
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# 设置标志
	music_option_selection_pending = true
	user_input_mode = true

# 生成自定义播放列表
func generate_custom_playlist(keywords):
	print("Generating custom playlist with keywords: ", keywords)
	
	# 检查是否是返回命令
	if keywords.to_lower().strip_edges() == "back":
		print("User requested to go back to music menu")
		custom_playlist_mode = false
		show_music_options()
		return
	
	# 设置模式标志
	custom_playlist_mode = false  # 生成完成后退出playlist模式
	is_showing_music = true
	user_input_mode = false
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 显示初始生成消息
	display_text_with_typing_effect("🎵 Starting to analyze your music preferences: \"" + keywords + "\"...")
	
	# 切换到思考动画
	change_animation(AnimState.THINKING)
	
	# 等待打字效果完成
	await get_tree().create_timer(1.0).timeout
	
	# 显示AI生成过程
	var generation_steps = [
		"🔍 Analyzing keyword characteristics...",
		"🧠 Matching music style database...",
		"✨ Applying rhythm preference algorithm...",
		"🎧 Evaluating emotional expression parameters...",
		"📊 Calculating optimal track combinations..."
	]
	
	# 显示生成过程的每一步
	for step in generation_steps:
		display_text_with_typing_effect(step)
		await get_tree().create_timer(randf_range(0.5, 1.2)).timeout
	
	# 显示生成中状态
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
	
	# 获取播放列表URL和标题 - 基于关键词匹配
	var playlist_url = ""
	var playlist_title = ""
	var playlist_description = ""
	var playlist_tracks = []
	var lower_keywords = keywords.to_lower().strip_edges()
	
	# 为不同关键词创建不同的"生成"播放列表
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
		# 创建一个基于关键词的"定制"播放列表
		playlist_url = "https://open.spotify.com/playlist/37i9dQZF1DWWQRwui0ExPn"
		
		# 动态创建播放列表标题
		var title_parts = []
		var keywords_array = lower_keywords.split(" ")
		for word in keywords_array:
			if word.length() > 3:  # 只使用较长的词
				title_parts.append(word.capitalize())
		
		if title_parts.size() > 0:
			playlist_title = " ".join(title_parts) + " Flow"
		else:
			playlist_title = "Personalized Focus Mix"
			title_parts = ["Focus"] # 添加默认值防止后面出错
		
		playlist_description = "Custom playlist based on your keywords \"" + keywords + "\""
		
		# 随机生成一些看起来与关键词相关的曲目
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
	
	# 切换到开心动画
	change_animation(AnimState.HAPPY)
	
	# 显示"发现中"的消息
	display_text_with_typing_effect("✨ Perfect match found! Integrating playlist...")
	
	# 等待短暂时间以提升期待感
	await get_tree().create_timer(1.0).timeout
	
	# 确保对话框可见
	$CanvasLayer/DialogPanel.visible = true
	
	# 完全清除并重新显示
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # 确保先清空
		dialog_label.clear()
	
	# 创建更精美的结果展示
	var header = "[center][color=#3498db][font_size=24]🎵 Your Custom Generated Playlist![/font_size][/color][/center]\n\n"
	
	var content = "[center][b][color=#e67e22][font_size=22]" + playlist_title + "[/font_size][/color][/b][/center]\n"
	content += "[center][i][color=#7f8c8d]" + playlist_description + "[/color][/i][/center]\n\n"
	
	# 添加曲目列表
	content += "[color=#2ecc71][font_size=18]Featured Tracks:[/font_size][/color]\n"
	for i in range(min(5, playlist_tracks.size())):
		content += "[color=#3498db]" + str(i+1) + ".[/color] " + playlist_tracks[i] + "\n"
	content += "\n"
	
	# 创建更大更明显的按钮样式链接
	content += "[center][url=" + playlist_url + "][color=#2ecc71][bgcolor=#1a1a2a][font_size=20]▶️  LISTEN ON SPOTIFY  ▶️[/font_size][/bgcolor][/color][/url][/center]\n\n"
	
	# 显示实际链接，方便用户复制
	content += "[center][color=#7f8c8d]" + playlist_url + "[/color][/center]\n\n"
	
	var footer = "[center][color=#e74c3c]🎧 This playlist was specially generated based on your keywords \"" + keywords + "\"[/color][/center]\n\n"
	footer += "[center][url=music_menu][color=#3498db]🔙 Back to Music Menu[/color][/url][/center]"
	
	# 显示结果
	display_text_with_rich_text(header + content + footer)
	
	# 切换到说话动画
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# 延迟后回到对话模式
	await get_tree().create_timer(2.0).timeout
	change_animation(AnimState.IDLE)

# 显示自定义播放列表界面
func show_custom_playlist_interface():
	# 设置模式标志
	custom_playlist_mode = true
	is_showing_music = true
	user_input_mode = false
	
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 显示加载中提示，给UI更新提供时间
	display_text_with_typing_effect("✨ Loading AI Playlist Generator...")
	
	# 播放思考动画
	change_animation(AnimState.THINKING)
	
	# 等待短暂时间以确保UI更新
	await get_tree().create_timer(0.5).timeout
	
	# 构建简化的关键词建议文本
	var header = "[center][color=#3498db][font_size=22]🎮 AI Playlist Generator[/font_size][/color][/center]\n\n"
	var intro = "[color=#2ecc71]✨ Enter keywords or mood, and I'll generate the perfect study playlist for you:[/color]\n\n"
	var examples_section = "[color=#f1c40f]💡 Try these examples:[/color]\n"
	
	# 添加示例提示
	examples_section += "[color=#e74c3c]•[/color] [b]focus jazz[/b] - Jazz music, perfect for enhancing focus\n"
	examples_section += "[color=#e74c3c]•[/color] [b]ninja vibe for final week[/b] - Dynamic rhythms for finals week\n"
	examples_section += "[color=#e74c3c]•[/color] [b]chill lofi[/b] - Relaxing Lo-Fi to help you study\n"
	examples_section += "[color=#e74c3c]•[/color] [b]classic piano study[/b] - Classical piano to aid your thinking\n\n"
	
	var suggestion = "[color=#f1c40f]💡 Other suggested keywords:[/color]\n"
	for keyword in music_keywords:
		suggestion += "[color=#e74c3c]•[/color] [b]" + keyword.keyword + "[/b] - " + keyword.description + "\n"
	
	var footer = "\n[color=#7f8c8d]💭 Enter any keywords you want, and AI will create a perfectly matched playlist for you![/color]\n\n"
	footer += "[url=back][color=#3498db]🔙 Back to Music Menu[/color][/url]"
	
	# 完全清除并重新显示
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # 确保先清空
	
	# 显示建议列表
	display_text_with_rich_text(header + intro + examples_section + suggestion + footer)
	
	# 切换到说话动画
	change_animation(AnimState.TALKING)
	
	# 等待动画效果完成
	await get_tree().create_timer(1.0).timeout
	
	# 显示输入容器
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# 设置用户输入模式，但维持自定义播放列表模式
	user_input_mode = true
	custom_playlist_mode = true

# 显示音乐歌单
func show_music_playlists():
	is_showing_music = true
	user_input_mode = false
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 显示加载中提示
	display_text_with_typing_effect("🔍 Finding the perfect study music for you...")
	
	# 播放开心动画
	change_animation(AnimState.HAPPY)
	
	# 等待动画和打字效果
	await get_tree().create_timer(1.5).timeout
	
	# 切换到说话动画
	change_animation(AnimState.TALKING)
	
	# 等待短暂时间以确保UI更新
	await get_tree().create_timer(0.5).timeout
	
	# 构建简化的歌单列表文本
	var header = "[center][color=#3498db][font_size=22]🎵 Focus Playlists[/font_size][/color][/center]\n"
	header += "[color=#7f8c8d]Click any playlist to open in Spotify[/color]\n\n"
	
	var content = ""
	for i in range(focus_playlists.size()):
		var playlist = focus_playlists[i]
		content += str(i+1) + ". [b][color=#f1c40f]" + playlist.name + "[/color][/b]\n"
		content += "   " + playlist.description + "\n"
		content += "   [url=" + playlist.url + "][color=#3498db]▶️ Play on Spotify[/color][/url]\n\n"
	
	var footer = "[url=music_menu][color=#3498db]🔙 Back to Music Menu[/color][/url]"
	
	# 完全清除并重新显示
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # 确保先清空
	
	# 显示歌单列表
	display_text_with_rich_text(header + content + footer)
	
	# 延迟后回到对话模式
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.IDLE)

# 显示课程列表
func show_course_selection():
	is_showing_music = false
	user_input_mode = true
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 构建课程列表文本
	var course_text = "📚 Available Courses:\n\n"
	for i in range(courses.size()):
		course_text += str(i + 1) + ". " + courses[i] + "\n"
	
	course_text += "\n✍️ Please enter the course number (1-" + str(courses.size()) + ") to view study plan..."
	
	# 显示课程列表
	display_text_with_typing_effect(course_text)
	
	# 显示输入容器
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()

# 显示学习计划
func show_study_plan():
	is_showing_music = false
	user_input_mode = false
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 播放思考动画
	change_animation(AnimState.THINKING)
	
	# 显示介绍文本
	$CanvasLayer/DialogPanel.visible = true
	display_text_with_typing_effect("🧠 Analyzing your exam needs and creating a 48-hour study plan...")
	
	# 等待打字效果完成
	await get_tree().create_timer(3).timeout
	
	# 切换到开心动画
	change_animation(AnimState.HAPPY)
	
	# 获取对话标签并设置滚动
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		# 确保是 RichTextLabel
		if dialog_label is RichTextLabel:
			dialog_label.scroll_active = true  # 启用滚动
			dialog_label.scroll_following = true  # 自动跟随文本
			dialog_label.scroll_to_line(0)  # 确保从顶部开始
			dialog_label.custom_minimum_size = Vector2(610, 450)  # 设置最小尺寸
			dialog_label.size = Vector2(610, 450)  # 设置固定尺寸
			dialog_label.fit_content = false  # 禁用自适应内容
			
			# 滚动条设置
			dialog_label.scroll_horizontal_enabled = false  # 禁用水平滚动
			dialog_label.scroll_vertical_enabled = true  # 启用垂直滚动
			dialog_label.scroll_vertical = 0  # 初始滚动位置
			dialog_label.scroll_following_smoothing = 3  # 滚动平滑度
			dialog_label.scroll_vertical_custom_step = 30  # 自定义滚动步长
			
			# 滚动条样式（可选）
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.2, 0.2, 0.2, 0.6)  # 滚动条背景色
			style.corner_radius_top_left = 3
			style.corner_radius_top_right = 3
			style.corner_radius_bottom_left = 3
			style.corner_radius_bottom_right = 3
			dialog_label.add_theme_stylebox_override("scroll", style)

	# 显示计划文本
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
	plan_text += "• 3 Hours: Practice writing clean, efficient code—pretend you’re coding in an interview.\n"
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
	
	# 切换到说话动画
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# 设置学习开始时间
	study_time_start = Time.get_unix_time_from_system()
	
	# 延迟后回到对话模式
	await get_tree().create_timer(7.0).timeout
	change_animation(AnimState.IDLE)
	show_user_input()

# 显示练习测试
func show_practice_test():
	is_showing_music = false
	user_input_mode = false
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 播放思考动画
	change_animation(AnimState.THINKING)
	
	# 显示介绍文本
	$CanvasLayer/DialogPanel.visible = true
	display_text_with_typing_effect("🧪 Let's test your knowledge to identify areas we need to focus on...")
	
	# 等待打字效果完成
	await get_tree().create_timer(2.0).timeout
	
	# 构建测试问题
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
	
	# 切换到说话动画
	change_animation(AnimState.TALKING)
	display_text_with_typing_effect(test_text)
	
	# 等待打字效果完成
	await get_tree().create_timer(3.0).timeout
	
	# 显示输入容器，但保留测试文本
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# 设置用户输入模式
	user_input_mode = true

# 显示健康提示
func show_health_tip():
	is_showing_music = false
	user_input_mode = false
	
	# 播放开心动画
	change_animation(AnimState.HAPPY)
	
	# 显示健康提示
	$CanvasLayer/DialogPanel.visible = true
	
	# 随机选择一条健康提示
	var tip = health_reminders[randi() % health_reminders.size()]
	display_text_with_typing_effect(tip + "\n\n(Type your next question or command...)")
	
	# 切换到说话动画
	await get_tree().create_timer(1.5).timeout
	change_animation(AnimState.TALKING)
	
	# 延迟后回到对话模式
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	show_user_input()

# 显示健康提醒弹窗
func show_health_reminder():
	# 只有在不显示其他内容时才显示健康提醒
	if not is_typing_text and not is_showing_music and not user_input_mode:
		# 显示健康提示
		show_health_tip()

# 处理测试回答
func process_test_answer(answer):
	var correct_answers = "1b 2c 3b"
	var score = 0
	
	# 简单比较答案
	var user_answers = answer.to_lower().strip_edges()
	var answers_array = user_answers.split(" ")
	var correct_array = correct_answers.split(" ")
	
	for i in range(min(answers_array.size(), correct_array.size())):
		if answers_array[i] == correct_array[i]:
			score += 1
	
	# 显示结果
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
	
	# 显示正确答案
	result_text += "\n\nCorrect answers:\n"
	result_text += "1. b) O(n²)\n"
	result_text += "2. c) Optimal substructure\n"
	result_text += "3. b) Heap\n\n"
	
	result_text += "(Type your next question or command...)"
	
	display_text_with_typing_effect(result_text)
	
	# 延迟后继续
	await get_tree().create_timer(3.0).timeout
	
	# 显示输入容器，但保留测试结果文本
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# 设置用户输入模式
	user_input_mode = true
	
	# 延迟后回到对话模式
	await get_tree().create_timer(0.5).timeout
	show_user_input()

# 点击桌宠时触发
func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("ClickArea signal triggered: Ninja cat clicked!")
		show_next_dialogue()
		return

# 处理用户输入文本框的回车事件
func _on_input_box_text_submitted(new_text):
	_on_send_button_pressed()  # 复用按钮的处理逻辑

# 处理用户输入的消息
func process_user_input(message):
	# 记录用户问题到对话历史
	conversation_history.append({"role": "user", "content": message})
	
	# 检查是否是测试答案
	if is_showing_music:
		return
	
	# 保存当前显示的文本，以便保持对话连续性
	var current_text = current_display_text
	
	# 如果当前文本已经包含"User:"，我们需要添加到现有对话中
	# 否则，只显示用户问题
	if "User:" in current_text:
		display_text_with_typing_effect(current_text + "\n\nUser: " + message)
	else:
		display_text_with_typing_effect("User: " + message)
	
	# 切换到说话动画表示收到问题
	change_animation(AnimState.TALKING)
	
	# 延迟一段时间
	await get_tree().create_timer(1.0).timeout
	
	# 显示AI思考过程
	show_ai_thinking_process(message)

# 显示AI思考过程
func show_ai_thinking_process(message):
	# 切换到思考动画
	change_animation(AnimState.THINKING)
	
	# 随机选择三个思考短语显示
	var selected_phrases = []
	var available_phrases = thinking_phrases.duplicate()
	for i in range(min(3, thinking_phrases.size())):
		var index = randi() % available_phrases.size()
		selected_phrases.append(available_phrases[index])
		available_phrases.remove_at(index)
	
	# 保存当前显示的文本，以便保持对话连续性
	var current_text = current_display_text
	
	# 显示思考过程，保持用户问题可见
	for phrase in selected_phrases:
		var thinking_text = current_text
		if not thinking_text.ends_with("\n\n"):
			thinking_text += "\n\n"
		thinking_text += phrase
		display_text_with_typing_effect(thinking_text)
		await get_tree().create_timer(0.8).timeout
	
	# 调用Gemini API获取回复
	call_gemini_api(message)

# 调用Gemini API
func call_gemini_api(message):
	# 检查API密钥
	if api_key.strip_edges().is_empty():
		print("API key is empty, using fallback response")
		use_fallback_response(message)
		return
	
	# 添加API测试检查
	print("Testing API access with key: " + api_key.substr(0, 5) + "...")

	# 创建HTTP请求
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_gemini_response_received)
	
	# 构建请求URL (包含API密钥)
	var url = GEMINI_API_URL + "?key=" + api_key
	
	# 准备请求头
	var headers = ["Content-Type: application/json"]
	
	# 增强提示语，让响应更像Final Ninja
	var system_prompt = "You are Final Ninja, a quirky pixel-art ninja character who helps students prepare for exams. Your mission is to help defeat the 'Final Monster' (exam stress) with efficient study strategies. Be encouraging, slightly humorous, and give concise, practical advice. Keep responses under 3 paragraphs. Focus on effective study techniques, time management, and mental well-being."
	
	# 构建请求体
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
	
	# 添加调试信息
	print("Sending API request to: " + GEMINI_API_URL)
	print("Request body: " + JSON.stringify(body))
	
	# 发送请求
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		print("Error making HTTP request: ", error)
		# 出错时显示危险动画
		change_animation(AnimState.DANGER)
		await get_tree().create_timer(1.0).timeout
		use_fallback_response("")

# 处理Gemini API响应
func _on_gemini_response_received(result, response_code, headers, body):
	var response_node = get_node_or_null("HTTPRequest")
	if response_node:
		response_node.queue_free()
	
	print("API Response Code: ", response_code)
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("Error in API response: ", response_code)
		# 打印响应体，帮助诊断
		print("Response body: ", body.get_string_from_utf8())
		# API错误时显示危险动画
		change_animation(AnimState.DANGER)
		await get_tree().create_timer(1.0).timeout
		use_fallback_response("")
		return
	
	# 解析响应
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("JSON Parse Error: ", parse_result)
		print("Response body: ", body.get_string_from_utf8())
		use_fallback_response("")
		return
	
	var response_data = json.get_data()
	print("Received valid response: ", JSON.stringify(response_data))
	
	# 从响应中提取文本 (根据Gemini API的响应结构调整)
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
	
	# 获取最后一个用户消息
	var last_user_message = ""
	if conversation_history.size() > 0:
		last_user_message = conversation_history[conversation_history.size() - 1].content
	
	# 添加API回复到对话历史
	conversation_history.append({"role": "assistant", "content": ai_message})
	
	# 切换到开心动画
	change_animation(AnimState.HAPPY)
	
	# 显示回复文本 - 同时显示用户问题和AI回答
	var display_text = ""
	if not last_user_message.is_empty():
		display_text = "User: " + last_user_message + "\n\n"
	
	display_text += "Final Ninja: " + ai_message + "\n\n(Type your next question or command...)"
	display_text_with_typing_effect(display_text)
	
	# 切换到说话动画
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# 延迟后回到对话模式
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	
	# 显示用户输入界面
	show_user_input()

# 使用备用回复
func use_fallback_response(message):
	print("Using fallback response")
	
	# 随机备用回复
	var fallback_replies = [
		"I seem to be having trouble connecting to my knowledge base. Could you try asking me in a different way?",
		"Hmm, my ninja senses are temporarily blocked. Let's try a different question!",
		"Even ninjas face challenges! I couldn't process that request. Could you rephrase it?",
		"My apologies, I'm having trouble formulating a response. Let's try another topic!"
	]
	
	var fallback_message = fallback_replies[randi() % fallback_replies.size()]
	
	# 获取最后一个用户消息
	var last_user_message = ""
	if message.strip_edges().is_empty() and conversation_history.size() > 0:
		last_user_message = conversation_history[conversation_history.size() - 1].content
	else:
		last_user_message = message
	
	# 添加备用回复到对话历史
	conversation_history.append({"role": "assistant", "content": fallback_message})
	
	# 切换到说话动画
	change_animation(AnimState.TALKING)
	
	# 显示回复文本 - 同时显示用户问题和备用回答
	var display_text = ""
	if not last_user_message.is_empty():
		display_text = "User: " + last_user_message + "\n\n"
	
	display_text += "Final Ninja: " + fallback_message + "\n\n(Type your next question or command...)"
	display_text_with_typing_effect(display_text)
	
	# 延迟后回到对话模式
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	
	# 显示用户输入界面
	show_user_input()

# 新增函数：使用富文本显示带链接的文本
func display_text_with_rich_text(text):
	# 停止当前的打字效果
	is_typing_text = false
	
	# 获取对话标签
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	
	# 如果当前标签不是RichTextLabel或无效，则创建一个新的
	if not dialog_label is RichTextLabel or not is_instance_valid(dialog_label):
		# 删除旧标签（如果存在）
		if dialog_label and is_instance_valid(dialog_label):
			# 保存当前标签的属性
			var current_pos = dialog_label.position
			var current_size = dialog_label.size
			var current_font_size = dialog_label.get_theme_font_size("font_size")
			dialog_label.queue_free()
			
			# 等待一帧确保删除完成
			await get_tree().process_frame
			
			# 创建RichTextLabel
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
			
			# 设置链接颜色和标签样式
			rich_text.add_theme_color_override("default_color", Color(1, 1, 1)) # 主文本白色
			rich_text.add_theme_color_override("font_selected_color", Color(0.8, 0.8, 0.8))
			rich_text.add_theme_constant_override("line_separation", 8) # 增加行间距防止重叠
			
			# 连接链接点击信号
			rich_text.connect("meta_clicked", _on_link_clicked)
			rich_text.connect("meta_hover_started", _on_link_hover_started)
			rich_text.connect("meta_hover_ended", _on_link_hover_ended)
			
			# 添加到对话面板
			$CanvasLayer/DialogPanel.add_child(rich_text)
			dialog_label = rich_text
		else:
			# 如果不存在标签，创建一个新的
			var rich_text = RichTextLabel.new()
			rich_text.name = "DialogLabel"
			rich_text.position = Vector2(10, 10) # 更新位置为10,10
			rich_text.size = Vector2(610, 350) # 更新大小为新设置的尺寸
			rich_text.bbcode_enabled = true
			rich_text.meta_underlined = true
			rich_text.add_theme_font_size_override("normal_font_size", 24) # 更新为24的字体大小
			rich_text.add_theme_font_size_override("bold_font_size", 26) # 粗体字再大一点
			rich_text.add_theme_font_size_override("italics_font_size", 24) # 斜体字大小
			rich_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			
			# 设置链接颜色和标签样式
			rich_text.add_theme_color_override("default_color", Color(1, 1, 1)) # 主文本白色
			rich_text.add_theme_constant_override("line_separation", 8) # 增加行间距防止重叠
			
			# 连接链接点击信号
			rich_text.connect("meta_clicked", _on_link_clicked)
			rich_text.connect("meta_hover_started", _on_link_hover_started)
			rich_text.connect("meta_hover_ended", _on_link_hover_ended)
			
			# 添加到对话面板
			$CanvasLayer/DialogPanel.add_child(rich_text)
			dialog_label = rich_text
	
	# 确保label存在
	if dialog_label and is_instance_valid(dialog_label):
		# 强制清除所有内容
		dialog_label.clear()
		dialog_label.text = ""
		
		# 等待一帧确保清除完成
		await get_tree().process_frame
		
		# 设置富文本内容
		dialog_label.clear()
		dialog_label.append_text(text)
		
		# 更新当前显示文本
		current_display_text = text
		full_text_to_display = text
	else:
		print("ERROR: Dialog label is null or invalid in display_text_with_rich_text")

# 处理链接点击
func _on_link_clicked(meta):
	print("Link clicked: ", meta)
	
	# 处理内部导航链接
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
		# 显示信息表示功能正在开发中
		var adhd_info = "This feature is currently in development...\n\n"
		adhd_info += "[url=adhd][color=#3498db]🔙 Back to ADHD Reader Mode[/color][/url]"
		display_text_with_rich_text(adhd_info)
		return
	elif meta == "adhd":
		show_adhd_reader_mode()
		return
	
	# 处理外部链接 (Spotify URLs)
	OS.shell_open(str(meta))

# 添加链接悬停效果处理函数
func _on_link_hover_started(meta):
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label) and dialog_label is RichTextLabel:
		# 添加悬停效果 - 播放微小的动画或音效
		$CanvasLayer/DialogPanel/DialogLabel.add_theme_constant_override("outline_size", 1)
		# 可以在这里添加更多悬停效果，比如播放声音
		# $AudioHover.play()

func _on_link_hover_ended(meta):
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label) and dialog_label is RichTextLabel:
		# 恢复正常状态
		$CanvasLayer/DialogPanel/DialogLabel.add_theme_constant_override("outline_size", 0)

# 显示ADHD阅读模式
func show_adhd_reader_mode():
	is_showing_music = false
	user_input_mode = false
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 显示加载中提示，给UI更新提供时间
	display_text_with_typing_effect("📱 Loading ADHD Reader Mode...")
	
	# 播放开心动画
	change_animation(AnimState.HAPPY)
	
	# 等待短暂时间以确保UI更新
	await get_tree().create_timer(0.5).timeout
	
	# 创建现代菜单，避免重叠和乱码问题
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
	
	# 完全清除并重新显示
	var dialog_label = $CanvasLayer/DialogPanel/DialogLabel
	if dialog_label and is_instance_valid(dialog_label):
		dialog_label.text = ""  # 确保先清空
	
	# 显示介绍文本加菜单
	display_text_with_rich_text("📱 ADHD Reader Mode can help you read and focus more easily!\n\n" + menu_text)
	
	# 切换到说话动画
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# 显示输入容器
	await get_tree().create_timer(0.5).timeout
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# 设置用户输入模式
	user_input_mode = true

# 显示排名
func show_ninja_ranking():
	is_showing_music = false
	user_input_mode = false
	
	# 显示对话框
	$CanvasLayer/DialogPanel.visible = true
	
	# 先清除当前显示的所有文本
	current_display_text = ""
	full_text_to_display = ""
	
	# 显示加载中提示
	display_text_with_typing_effect("🥷 Loading Ninja Community Rankings...")
	
	# 播放思考动画
	change_animation(AnimState.THINKING)
	
	# 等待短暂时间以确保UI更新
	await get_tree().create_timer(1.0).timeout
	
	# 创建排名内容
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
	
	# 显示排名文本
	display_text_with_typing_effect(rankings_text)
	
	# 切换到说话动画
	await get_tree().create_timer(1.0).timeout
	change_animation(AnimState.TALKING)
	
	# 延迟后回到空闲状态
	await get_tree().create_timer(3.0).timeout
	change_animation(AnimState.IDLE)
	
	# 显示输入容器
	var input_container = $CanvasLayer/DialogPanel/InputContainer
	input_container.visible = true
	
	# 清空并聚焦输入框
	var input_box = $CanvasLayer/DialogPanel/InputContainer/InputBox
	input_box.text = ""
	input_box.grab_focus()
	
	# 设置用户输入模式
	user_input_mode = true

var dragging = false
var drag_start_position = Vector2()
var window_start_position = Vector2i()

func _input(event):
	# 处理键盘输入
	if event is InputEventKey and event.pressed:
		var window = get_window()
		var current_position = window.position
		var new_position = current_position
		
		# 检测方向键输入
		match event.keycode:
			KEY_UP:
				new_position.y -= window_move_speed # 向上移动
			KEY_DOWN:
				new_position.y += window_move_speed # 向下移动
			KEY_LEFT:
				new_position.x -= window_move_speed # 向左移动
			KEY_RIGHT:
				new_position.x += window_move_speed # 向右移动
		
		# 应用新位置
		if new_position != current_position:
			window.position = new_position
	
	# 处理鼠标点击事件
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 检查点击位置是否在精灵上
		var sprite = $Sprite2D
		var sprite_pos = sprite.global_position
		var sprite_size = sprite.texture.get_size() * sprite.scale
		var mouse_pos = event.position
		
		var left = sprite_pos.x - sprite_size.x/2
		var right = sprite_pos.x + sprite_size.x/2
		var top = sprite_pos.y - sprite_size.y/2
		var bottom = sprite_pos.y + sprite_size.y/2
		
		# 点击忍者猫时显示对话
		if mouse_pos.x > left and mouse_pos.x < right and mouse_pos.y > top and mouse_pos.y < bottom:
			print("Click detected on ninja sprite")
			show_next_dialogue()
			return
		
		# 检查点击是否在对话框上
		var dialog_panel = $CanvasLayer/DialogPanel
		if dialog_panel and dialog_panel.visible:
			var dialog_rect = Rect2(dialog_panel.global_position, dialog_panel.size)
			
			# 如果点击在对话框上（排除输入框区域）
			if dialog_rect.has_point(mouse_pos):
				var input_container = $CanvasLayer/DialogPanel/InputContainer
				var input_rect = Rect2()
				
				# 检查是否点击在输入框区域
				if input_container and input_container.visible:
					input_rect = Rect2(input_container.global_position, input_container.size)
				
				# 如果点击不在输入框区域，则触发对话继续
				if not input_rect.has_point(mouse_pos) and not is_typing_text:
					print("Click detected on dialog panel")
					if user_input_mode:
						# 如果处于用户输入模式，点击对话框没有效果
						pass
					else:
						# 如果不是在打字效果中，继续下一条对话或显示输入界面
						show_next_dialogue()
						return
