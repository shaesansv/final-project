from flask import Flask, request, jsonify
from flask_cors import CORS
from vulnerabilities.sql_injection import test_sql_injection
from vulnerabilities.xss import test_xss
from vulnerabilities.csrf import test_csrf
from vulnerabilities.open_redirect import test_open_redirect
from vulnerabilities.security_headers import test_security_headers

app = Flask(__name__)
CORS(app)

@app.route('/scan', methods=['POST'])
def scan():
    data = request.json
    url = data.get('url')

    if not url:
        return jsonify({"error": "URL is required"}), 400

    # Perform vulnerability tests
    sql_injection_result = test_sql_injection(url)
    xss_result = test_xss(url)
    csrf_result = test_csrf(url)
    open_redirect_result = test_open_redirect(url)
    security_headers_result = test_security_headers(url)

    results = {
        "sql_injection": sql_injection_result,
        "xss": xss_result,
        "csrf": csrf_result,
        "open_redirect": open_redirect_result,
        "security_headers": security_headers_result
    }

    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True)
