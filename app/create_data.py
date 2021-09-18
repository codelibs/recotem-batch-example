import sys
from pathlib import Path

import pandas as pd
from irspack.dataset.movielens import MovieLens1MDataManager


def _create_df() -> pd.DataFrame:
    # TODO create your data
    loader = MovieLens1MDataManager(force_download=True)
    df = loader.read_interaction()
    return df.rename(columns={"movieId": "itemId"})[["userId", "itemId", "timestamp"]]


if __name__ == "__main__":
    csv_file: str = Path(sys.argv[1])
    df = _create_df()
    df.to_csv(csv_file, index=False)
