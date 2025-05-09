
# course code
target_course = ["9131", "9132", "9136", "9137", "5057",
                 "5125", "5136", "5137", "5046", "5225",
                 "5120", "5122", "5032"]

# learning.monash.edu/my/  JavaScript script
my_js_code = """
        function shouldAddBorder(element) {
            //  class="mt-3"、"d-flex"、"w-100 text-truncate"  <div> add border
            if (element.tagName.toLowerCase() === "div") {
                if ((element.classList.length === 1 && (element.classList.contains("mt-3") || element.classList.contains("d-flex"))) || 
                    (element.classList.length === 2 && element.classList.contains("w-100") && element.classList.contains("text-truncate")) ) {
                    return true; 
                }
            }

            //  class="mb-0"  <small>  add border
            if (element.tagName.toLowerCase() === "small" && element.classList.length === 1 && element.classList.contains("mb-0")) {
                return true; 
            }

            // data-action="view-event" <a> add border
            if (element.tagName.toLowerCase() === "a" && element.getAttribute("data-action") === "view-event") {
                return true; 
            }

            return false; 
        }

        var elements = document.querySelectorAll("div, small, a"); // get all <div>, <small>, <a> 
        elements.forEach(function(element) {
            if (shouldAddBorder(element)) {
                var color = "#" + Math.floor(Math.random()*16777215).toString(16); // generate random color
                element.style.border = "2px solid " + color;
            }
        });
        """

specific_week_js_code = """
(function() {
    var colorIndex = 0;

    function hasBorder(element) {
        return window.getComputedStyle(element).borderWidth !== '0px';
    }

    function highlightElement(element) {
        var color = "#" + Math.floor(Math.random()*16777215).toString(16); // generate random color
        element.style.border = "2px solid " + color;
        element.style.borderRadius = '5px';
        element.style.padding = '3px';
        colorIndex++;
    }

    // 1️⃣ highlight the elements as the same level as the "Schedule"
    let scheduleElement = document.querySelector('a.courseindex-link.text-truncate');
    if (scheduleElement && scheduleElement.innerText.trim() === 'Schedule') {
        let parent = scheduleElement.parentElement;
        if (parent) {
            parent.querySelectorAll(':scope > *').forEach(el => {
                if (el !== scheduleElement && !hasBorder(el)) {
                    highlightElement(el);
                }
            });
        }
    }

    // 2️⃣ process specific class <div>
    document.querySelectorAll('div[class="format-mst"], div[class="activity-item"], div[class="courseindex"]').forEach(div => {
        if (!hasBorder(div) && !div.querySelector('div[style*="border"]')) {
            highlightElement(div);
        }
    });

    // 3️⃣ highlight <strong>
    document.querySelectorAll('strong').forEach(el => {
        if (!hasBorder(el)) {
            highlightElement(el);
        }
    });

    // 4️⃣ hightlight <p> if content is not empty
    document.querySelectorAll('p').forEach(el => {
        if (el.innerText.trim().length > 0 && !hasBorder(el)) {
            highlightElement(el);
        }
    });

    // 5️⃣ hightlight table
    document.querySelectorAll('table').forEach(table => {
        if (!hasBorder(table)) {
            highlightElement(table);
        }
    });

    // 6️⃣ highlight <a href> && content length < 20
    document.querySelectorAll('a[href]').forEach(a => {
        let text = a.innerText.trim();
        if (text.length > 0 && text.length < 20 && !hasBorder(a)) {  
            highlightElement(a);
        }
    });

    // 7️⃣ highlight specific class
    document.querySelectorAll('a.courseindex-link.text-truncate').forEach(a => {
        if (a.className.trim() === 'courseindex-link text-truncate' && !hasBorder(a)) {
            highlightElement(a);
        }
    });

    document.querySelectorAll('.nav-link').forEach(el => {
        if (el.className.trim() === 'nav-link' && !hasBorder(el)) {
            highlightElement(el);
        }
    });

    document.querySelectorAll('.activity-item').forEach(el => {
        if (el.className.trim() === 'activity-item' && !hasBorder(el)) {
            highlightElement(el);
        }
    });

    // 8️⃣ exclude <a role="button">
    document.querySelectorAll('a[role="button"]').forEach(a => {
        a.style.border = 'none';
    });

})();
"""

timeline_js_code = """
(function() {
    const colors = ['#ff4500', '#32cd32', '#1e90ff', '#ff69b4', '#8a2be2', '#ffa500'];  
    document.querySelectorAll('.widget-container_widgetCard__hq1UB').forEach(element => {
        let randomColor = colors[Math.floor(Math.random() * colors.length)];
        element.style.border = `3px solid ${randomColor}`;
        element.style.borderRadius = '5px';
        element.style.padding = '3px';
    });
})();
"""
