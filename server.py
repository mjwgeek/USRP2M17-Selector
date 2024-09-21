from flask import Flask, request, jsonify, render_template_string, send_from_directory
import subprocess
import os 

app = Flask(__name__)

@app.route('/m17/')
def index():
    return render_template_string(open('/var/www/html/m17/index.html').read())

@app.route('/m17/reflector_options.txt')
def reflector_options():
    return send_from_directory('/var/www/html/m17', 'reflector_options.txt')

@app.route('/m17/connect', methods=['POST'])  # Corrected this line
def connect_reflector():
    data = request.json
    reflector = data.get('reflector')
    module = data.get('module')

    try:
        # Call the shell script to update the ini file and restart the service
        subprocess.run(['/var/www/html/m17/update_usrp2m17.sh', reflector, module], check=True)
        return jsonify(message="Service restarted successfully"), 200
    except subprocess.CalledProcessError as e:
        return jsonify(error=str(e)), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)

application = app
