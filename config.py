OPENAI_API_KEY = "sk-"
OPENAI_API_URL = "https://api.openai.com/v1/"

# 课程编号
target_course = ["9131", "9132", "9136", "9137", "5057",
                 "5125", "5136", "5137", "5046", "5225",
                 "5120", "5122", "5032"]

# learning.monash.edu/my/ 页面的 JavaScript 代码
my_js_code = """
        function shouldAddBorder(element) {
            // 仅对 class="mt-3"、"d-flex"、"w-100 text-truncate" 的 div 添加边框
            if (element.tagName.toLowerCase() === "div") {
                if ((element.classList.length === 1 && (element.classList.contains("mt-3") || element.classList.contains("d-flex"))) || 
                    (element.classList.length === 2 && element.classList.contains("w-100") && element.classList.contains("text-truncate")) ) {
                    return true; // 如果符合条件，返回添加边框的标识
                }
            }

            // 仅对 class="mb-0" 的 small 标签添加边框
            if (element.tagName.toLowerCase() === "small" && element.classList.length === 1 && element.classList.contains("mb-0")) {
                return true; // 如果符合条件，返回添加边框的标识
            }

            // 仅对 data-action="view-event" 的 a 标签添加边框
            if (element.tagName.toLowerCase() === "a" && element.getAttribute("data-action") === "view-event") {
                return true; // 如果符合条件，返回添加边框的标识
            }

            return false; // 不符合条件
        }

        var elements = document.querySelectorAll("div, small, a"); // 获取所有 div, small, a 标签
        elements.forEach(function(element) {
            if (shouldAddBorder(element)) {
                var color = "#" + Math.floor(Math.random()*16777215).toString(16); // 生成随机颜色
                element.style.border = "2px solid " + color;
            }
        });
        """