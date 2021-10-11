# speedr
This is an R package to access the Enrichr API. The package supports listing gene sets, enrichment analysis of selected gene set library with and without background correction. The R package links to a derivation of the enrichr API.

## Installation 
```
library(devtools)
install_github("MaayanLab/speedr/speedr")
```

## Examples

List supported gene set libraries
```R
library("speedr")

libraries <- speedr::list_libraries()
```

Enrichment analysis without background correction
```R
library("speedr")

library = "GO_Biological_Process_2021"
genes = c('PTPN18','EGF','HSP90AA1','GAB1','NRG1','MATK','PTPN12','NRG2','PTK6','PRKCA','ERBIN','EREG','BTC','NRG4','PIK3R1','PIK3CA','CDC37','GRB2','STUB1','HBEGF','GRB7')

result <- speedr::enrich(library, genes)
```


Enrichment analysis with background correction
```R
library("speedr")

library = "GO_Biological_Process_2021"
background = c('TGFB1', 'EOMES', 'TGFB2', 'DDX17', 'NOG', 'FOXF2', 'WNT5A', 'HGF', 'HMGA2', 'HNRNPAB', 'PTPN18','EGF','HSP90AA1','GAB1','NRG1','MATK','PTPN12','NRG2','PTK6','PRKCA','ERBIN','EREG','BTC','NRG4','PIK3R1','PIK3CA','CDC37','GRB2','STUB1','HBEGF','GRB7')
genes = c('TGFB1', 'EOMES', 'TGFB2', 'DDX17', 'NOG', 'FOXF2', 'WNT5A', 'HGF', 'HMGA2', 'HNRNPAB', 'PTPN18','EGF','HSP90AA1','GAB1','NRG1','MATK','PTPN12','NRG2','PTK6','PRKCA','ERBIN','EREG','BTC','NRG4','PIK3R1','PIK3CA','CDC37','GRB2','STUB1','HBEGF','GRB7')

result <- speedr::enrich(library, genes, background)

```
