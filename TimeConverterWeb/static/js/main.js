async function convert() {
    const input = document.getElementById('input').value;
    const timezone = document.getElementById('timezone').value;
    const errorDiv = document.getElementById('error');
    const resultDiv = document.getElementById('result');
    
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
    }
}

function formatResult(result) {
    return `Date: ${result.date}
Timestamp (ns):  ${result.timestamp_ns}
Timestamp (μs):  ${result.timestamp_us}
Timestamp (ms):  ${result.timestamp_ms}
Timestamp (s):   ${result.timestamp_s}`;
}

// Add keyboard shortcuts
document.addEventListener('keydown', function(event) {
    if (event.key === 'Enter') {
        convert();
    } else if (event.key === 'c' && event.metaKey) {
        const resultDiv = document.getElementById('result');
        if (resultDiv.textContent) {
            navigator.clipboard.writeText(resultDiv.textContent);
        }
    }
}); 