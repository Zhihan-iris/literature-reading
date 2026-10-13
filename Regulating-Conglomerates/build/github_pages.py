import subprocess,os,json,sys,urllib.request,urllib.error
repo='Zhihan-iris/literature-reading'
env=dict(os.environ,GIT_TERMINAL_PROMPT='0')
r=subprocess.run(['git','credential','fill'],input='protocol=https\nhost=github.com\n\n',text=True,capture_output=True,env=env,timeout=20)
cred=dict(x.split('=',1) for x in r.stdout.splitlines() if '=' in x)
if not cred.get('password'):
 print(json.dumps({'authenticated':False,'reason':'No Git credential available'}));sys.exit(2)
def api(path,method='GET',body=None):
 config='url = '+json.dumps('https://api.github.com/'+path)+'\nrequest = '+json.dumps(method)+'\n'
 for header in ['Authorization: Bearer '+cred['password'],'Accept: application/vnd.github+json','X-GitHub-Api-Version: 2022-11-28','User-Agent: literature-reading-lecture','Content-Type: application/json']:
  config+='header = '+json.dumps(header)+'\n'
 if body is not None:config+='data = '+json.dumps(json.dumps(body))+'\n'
 result=subprocess.run(['curl','--ipv4','--http1.1','--silent','--show-error','--max-time','30','--config','-'],input=config,text=True,capture_output=True,timeout=35)
 try:return json.loads(result.stdout)
 except json.JSONDecodeError:return {'error':'GitHub API connection failed','exit_code':result.returncode}

mode=sys.argv[1] if len(sys.argv)>1 else 'status'
if mode=='status':
 info=api('repos/'+repo);pages=api('repos/'+repo+'/pages')
 print(json.dumps({'authenticated':True,'permissions':info.get('permissions'),'pages':pages},ensure_ascii=False))
elif mode=='enable':
 current=api('repos/'+repo+'/pages')
 if str(current.get('status'))=='404': current=api('repos/'+repo+'/pages','POST',{'source':{'branch':'main','path':'/'}})
 print(json.dumps(current,ensure_ascii=False))
elif mode=='build':
 print(json.dumps(api('repos/'+repo+'/pages/builds/latest'),ensure_ascii=False))
