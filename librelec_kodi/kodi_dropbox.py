
# Set API key
# https://www.dropbox.com/developers/apps/info/v5hlkpjo7bqbqnn#settings
# And pip install dropbox


import dropbox
from dropbox import DropboxOAuth2FlowNoRedirect

# Remplacez ces valeurs par vos propres clés d'API
APP_KEY = '******'
APP_SECRET = '*****'
ACCESS_TOKEN = '******************'

def auth_dropbox():
    auth_flow = DropboxOAuth2FlowNoRedirect(APP_KEY, APP_SECRET)

    authorize_url = auth_flow.start()
    print("1. Go to: " + authorize_url)
    print("2. Click \"Allow\" (you might have to log in first).")
    print("3. Copy the authorization code.")
    auth_code = input("Enter the authorization code here: ").strip()

    try:
        oauth_result = auth_flow.finish(auth_code)
    except Exception as e:
        print('Error: %s' % (e,))
        exit(1)

    with dropbox.Dropbox(oauth2_access_token=oauth_result.access_token) as dbx:
        dbx.users_get_current_account()
        print("Successfully set up client!")

def upload_to_dropbox(access_token, content):
    try:
        dbx = dropbox.Dropbox(access_token)

        # Contenu à écrire dans le fichier
        file_content = content.encode('utf-8')

        # Chemin du fichier dans Dropbox
        file_path = '/KIDS/librelec_timer.txt'

        # Télécharger le contenu actuel du fichier (s'il existe)
        try:
            existing_file = dbx.files_download(file_path)[1].content.decode('utf-8')
        except dropbox.exceptions.HttpError as e:
            existing_file = ""

        # Si le contenu du fichier est différent, mettez à jour le fichier
        if existing_file != content:
            dbx.files_upload(file_content, file_path, mode=dropbox.files.WriteMode.overwrite)
            print("Fichier mis à jour avec succès.")
        else:
            print("Le fichier est déjà à jour.")

    except dropbox.exceptions.AuthError as e:
        print(f"Erreur d'authentification Dropbox: {e}")
    except dropbox.exceptions.ApiError as e:
        print(f"Erreur Dropbox API: {e}")

if __name__ == "__main__":
    access_token = ACCESS_TOKEN or auth_dropbox()

    if access_token:
        content = input("Entrez la valeur à mettre à jour dans le fichier (1 ou 0): ")
        upload_to_dropbox(access_token, content)
