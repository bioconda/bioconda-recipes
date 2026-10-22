"""Temporary bounded native Mac diagnostic, removed before merge."""
import glob,json,os,signal,subprocess,time
from pathlib import Path

def bounded(argv):
    print('[DEBUG-bioconda-mac]',argv,flush=True)
    env=dict(os.environ);env.pop('SDKROOT',None)
    p=subprocess.Popen(argv,env=env,start_new_session=True)
    try:p.wait(timeout=45)
    except subprocess.TimeoutExpired:
        os.killpg(p.pid,signal.SIGKILL);p.wait();print('[DEBUG-bioconda-mac] timed out',flush=True)
    print('[DEBUG-bioconda-mac] exit',p.returncode,flush=True)

bounded(['./native-diagnostic','tests/fixtures/anim/identical.r.fa','tests/fixtures/anim/identical.q.fa','native-direct'])
bounded(['xcrun','--sdk','macosx','lldb','--batch','-o','settings set auto-confirm true','-o','run','-o','thread backtrace all','--','./native-diagnostic','tests/fixtures/anim/identical.r.fa','tests/fixtures/anim/identical.q.fa','native-probe'])
for path in sorted((Path.home()/'Library/Logs/DiagnosticReports').glob('native-diagnostic*.ips'))[-2:]:
    text=path.read_text();decoder=json.JSONDecoder();_,end=decoder.raw_decode(text)
    try:body=json.loads(text[end:].strip())
    except ValueError:continue
    print('[DEBUG-bioconda-mac] crash',path.name,flush=True)
    images=body.get('usedImages',[])
    for thread in body.get('threads',[]):
        if thread.get('triggered'):
            for frame in thread.get('frames',[])[:25]:
                index=frame.get('imageIndex');name=images[index].get('name') if isinstance(index,int) and index<len(images) else None
                print(json.dumps({'image':name,**frame}),flush=True)
