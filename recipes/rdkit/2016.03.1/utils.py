from __future__ import print_function

import requests


# http://stackoverflow.com/questions/16694907/how-to-download-large-file-in-python-with-requests-py
def download_file(url):
    r = requests.get(url, stream=True)
    filename = url.split('/')[-1]
    with open(filename, 'wb') as f:
        print("Downloading: ", filename)
        for chunk in r.iter_content(chunk_size=8192): 
            if chunk: # filter out keep-alive new chunks
                f.write(chunk)
                f.flush()
    return filename


