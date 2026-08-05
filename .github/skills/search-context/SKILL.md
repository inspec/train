---
name: search-context
description: Search the shared context system for information. Use this whenever the AI or human needs contextual information about the products.
---

## Initialization Required

If `context/shared/map.md` does not exist, run /start-developement.

## Load Context Map

Load the context map. Understand the context types. Understand the levels of detail.

## Figure Out How to Walk the Levels Of Specificity

Ideally, the first time you search, you will discover how to search by learning the answers to these questions.  

### Need to know repo

Determine which repository you are working in. This can usually be determined from git remote -v.

### Need to know if repo uses local context or shared context

Check for `context/shared/by-repo/ORG/REPO`. If so, anticipate searching per-repo context there.
If not, anticipate searching per-repo context at `context/local`.

### Need to know product

Determine product info from the per-repo `background/product-info.md` file. This determines `context/shared/by-product/PRODUCT/` search entries. There may be zero or multiple product associations.

### Need to know division

Determine which division produces the product from the per-repo `background/product-info.md` file. This determines `context/shared/by-division/DIVISION/` search entries. There may be zero or multiple division associations.

### Need to know business unit

Determine which business unit produces the product from the per-repo `background/product-info.md` file. This determines `context/shared/by-business-unit/UNIT/` search entries. There may be zero or multiple unit associations.

## Determine type of query

Decide if you are looking for designs, background, specifications, or what, based on the context types listed in the Context Map.

## Construct queries

You don't have to use grep, but these are examples.

```bash
grep -r context/shared/global/progress/background/**/*.md 'string'
grep -r context/shared/by-business-unit/infra/background/**/*.md 'string'
grep -r context/shared/by-division/chef/background/**/*.md 'string'
grep -r context/shared/by-product/chef-infra-client/background/**/*.md 'string'
grep -r context/shared/by-repo/chef/chef/background/**/*.md 'string'
```

```bash
grep -r context/shared/global/progress/standards/**/*.md 'string'
grep -r context/shared/by-business-unit/infra/standards/**/*.md 'string'
grep -r context/shared/by-division/next/standards/**/*.md 'string'
grep -r context/shared/by-product/alsi/standards/**/*.md 'string'
grep -r context/local/standards/**/*.md 'string'
```

## Reconcile Results

You will likely have multiple results.  Merge the results and reconcile contradictions as follows:

1. Policy specifications higher in the tree are more influential. So a division-level standard should generally apply more than a product-level standard.
2. Technical specifications lower in the tree override specs context higher in the tree. So a technical specification to use a particular driver api might be needed for a good reason (which must be justified) and this override a higher-level mandate.
3. Any confusion or unresolved issues should be brough to the user's attention for a decision.
