import csv,json,subprocess
from pathlib import Path
def run(*args):
 r=subprocess.run(['kaksturbo',*args],text=True,capture_output=True)
 if r.returncode:
  raise RuntimeError(f"kaksturbo {args!r} exited {r.returncode}; stdout={r.stdout!r}; stderr={r.stderr!r}")
 return r.stdout
assert run('--version').strip() == 'KaKsTurbo 1.1.0'
assert 'resume' in run('--help')
assert json.loads(run('doctor','--backend','cpu','--json'))['PASS']
assert json.loads(run('validate','--input','examples/three_pair_smoke.axt','--json'))['pairs']==3
payload=json.loads(run('run','--input','examples/three_pair_smoke.axt','--output','test_results','--backend','cpu','--threads','2','--max-seconds','120','--json'))
assert payload['complete'] and payload['count']==3
rows=list(csv.DictReader(open('test_results/result.tsv'),delimiter='\t'))
assert [r['pair_id'] for r in rows]==['forward','reverse','identical']
assert sum(r['Ka_Ks']=='NA' for r in rows)==1
quality=json.loads(Path('test_results/quality_summary.json').read_text())
assert quality['gradient_threshold']==1e-8
manifest=json.loads(Path('test_results/run_manifest.json').read_text())
assert manifest['model_count']==14 and manifest['config']['max_iterations']==500
assert sum(1 for _ in open('test_results/models.jsonl'))==42
assert json.loads(run('resume','test_results','--json'))['complete']
print('Native conda installation and three-pair smoke PASS (not a benchmark).')
