import sys,runpy,subprocess,base64,re,datetime,json
from pathlib import Path
sys.argv=['github_pages.py','api-only']
a=runpy.run_path('.work/github_pages.py');api=a['api'];repo='repos/Zhihan-iris/literature-reading/'
def git(*args):return subprocess.check_output(['git','-C','literature-reading',*args],text=True).strip()
def call(path,method='GET',body=None,key=None):
 r=api(repo+path,method,body)
 if key and key not in r:raise RuntimeError(str(r))
 return r
head=git('rev-parse','HEAD');parent=git('rev-parse','HEAD^');target=call('git/ref/heads/main',key='object')['object']['sha']
if target==head:print('Commit already published',head);sys.exit(0)
if target!=parent:raise RuntimeError('Remote branch changed; no update performed: '+target)
entries=[]
for f in git('diff-tree','--no-commit-id','--name-only','-r','HEAD').splitlines():
 content=(Path('literature-reading')/f).read_bytes()
 blob=call('git/blobs','POST',{'content':base64.b64encode(content).decode(),'encoding':'base64'},'sha')
 entries.append({'path':f,'mode':'100644','type':'blob','sha':blob['sha']});print('Uploaded',f,flush=True)
tree=call('git/trees','POST',{'base_tree':git('rev-parse','HEAD^:') ,'tree':entries},'sha')['sha']
assert tree==git('rev-parse','HEAD:'),'Tree mismatch'
raw=subprocess.check_output(['git','-C','literature-reading','cat-file','-p','HEAD'],text=True);headers,message=raw.split('\n\n',1)
def person(role):
 line=next(x for x in headers.splitlines() if x.startswith(role+' '));m=re.match(r'.*? (.+) <([^>]+)> (\d+) ([+-])(\d\d)(\d\d)$',line);name,email,ts,sign,hh,mm=m.groups();off=(int(hh)*60+int(mm))*(1 if sign=='+' else -1);date=datetime.datetime.fromtimestamp(int(ts),datetime.timezone(datetime.timedelta(minutes=off))).isoformat();return {'name':name,'email':email,'date':date}
commit=call('git/commits','POST',{'message':message,'tree':tree,'parents':[parent],'author':person('author'),'committer':person('committer')},'sha')['sha']
assert commit==head,'Commit differs; branch left unchanged: '+commit
assert call('git/ref/heads/main',key='object')['object']['sha']==parent,'Remote changed during upload'
r=call('git/refs/heads/main','PATCH',{'sha':head,'force':False},'object');print('Published exact commit',r['object']['sha'])
