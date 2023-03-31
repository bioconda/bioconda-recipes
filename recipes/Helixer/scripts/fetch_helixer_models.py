#! /usr/bin/env python3

import argparse
from collections import defaultdict
from helixer.core.data import prioritized_models, fetch_and_organize_models


def main(lineage=None, best_only=True):
    """downloads (best) model(s) for indicated lineage"""
    if best_only:
        end = 1
    else:
        end = float('inf')
    priority_ms = prioritized_models(lineage)
    by_lineage = defaultdict(lambda: [])
    for model in priority_ms:
        by_lineage[model['lineage']].append(model)

    for models in by_lineage.values():
        models = models[:min(len(models), end)]
        fetch_and_organize_models(models)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--lineage', help='download model(s) for <lineage> leave unset for all lineages')
    parser.add_argument('-a', '--all', action='store_true', help='set this to download all, and not just best'
                                                                 'model. This might be helpful if you plan to ensemble'
                                                                 'multiple models. Note that Helixer.py will continue'
                                                                 'to use only the best model for a lineage by default.')
    args = parser.parse_args()
    main(args.lineage, best_only=not args.all)
