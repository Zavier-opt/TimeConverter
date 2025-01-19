// 添加事件监听器
document.addEventListener('DOMContentLoaded', function() {
    // 获取输入框和按钮元素
    const inputElement = document.getElementById('input');
    const convertBtn = document.getElementById('convertBtn');
    
    // 为输入框添加回车键事件
    inputElement.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            convert();
        }
    });
    
    // 为转换按钮添加点击事件
    convertBtn.addEventListener('click', function() {
        convert();
    });
});

async function convert() {
    const input = document.getElementById('input').value;
    const timezone = document.getElementById('timezone').value;
    const errorDiv = document.getElementById('error');
    const resultDiv = document.getElementById('result');
    
    // 禁用按钮，显示加载状态
    const convertBtn = document.getElementById('convertBtn');
    convertBtn.disabled = true;
    convertBtn.textContent = 'Converting...';
    
    try {
        const response = await fetch('/convert', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ input, timezone })
        });
        
        const data = await response.json();
        
        if (data.success) {
            errorDiv.textContent = '';
            resultDiv.textContent = data.results.map(formatResult).join('\n\n');
        } else {
            errorDiv.textContent = data.error;
            resultDiv.textContent = '';
        }
    } catch (error) {
        errorDiv.textContent = 'An error occurred. Please try again.';
        resultDiv.textContent = '';
    } finally {
        // 恢复按钮状态
        convertBtn.disabled = false;
        convertBtn.textContent = 'Convert';
    }
}

function formatResult(result) {
    return `Date: ${result.date}
Timestamp (ns):  ${result.timestamp_ns}
Timestamp (μs):  ${result.timestamp_us}
Timestamp (ms):  ${result.timestamp_ms}
Timestamp (s):   ${result.timestamp_s}`;
}

// 添加键盘快捷键
document.addEventListener('keydown', function(event) {
    if (event.key === 'c' && (event.metaKey || event.ctrlKey)) {
        const resultDiv = document.getElementById('result');
        if (resultDiv.textContent) {
            navigator.clipboard.writeText(resultDiv.textContent);
        }
    }
}); 