import numpy as np
import pandas as pd
from reComBat import reComBat

rng = np.random.default_rng(0)
batches = pd.Series(["a"] * 4 + ["b"] * 4 + ["c"] * 4)
shifts = batches.map({"a": 0.0, "b": 1.0, "c": -0.5}).to_numpy()[:, None]
data = pd.DataFrame(rng.normal(5, 1, (12, 50)) + shifts)

model = reComBat(parametric=True, model="elastic_net", config={"alpha": 1e-9}, verbose=False)
corrected = np.asarray(model.fit_transform(data, batches))

assert corrected.shape == data.shape
assert np.isfinite(corrected).all()
batch_means = [corrected[batches.to_numpy() == b].mean() for b in "abc"]
assert np.ptp(batch_means) < np.ptp([data[batches == b].to_numpy().mean() for b in "abc"])
