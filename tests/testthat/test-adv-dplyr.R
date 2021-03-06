library(testthat)
library(dplyr)
context("adv-dplyr")


library(maptools)
library(dplyr)
data(wrld_simpl)
poly1 <- wrld_simpl
line1 <- as(wrld_simpl, "SpatialLinesDataFrame")
point1 <- as(line1, "SpatialPointsDataFrame")
test_that("group by and summarize is quiet", {
  testthat::skip_on_cran()
expect_silent(g <- wrld_simpl  %>% group_by(REGION)  %>% summarize(alon = mean(LON), mxlat = max(LAT), mxarea = max(AREA)))
})


#mpoint1 <- SpatialMultiPointsDataFrame(lapply(split(line1, seq(nrow(line1))), function(y) coordinates(as(y, "SpatialPoints"))), 
#                                       as.data.frame(line1))
# filter() (and slice())
# arrange()
# select() (and rename())
# distinct()
# mutate() (and transmute())
# summarise()
# sample_n() and sample_frac()
# 
# group_by and summarize
# 
# inner_join()	SELECT * FROM x JOIN y ON x.a = y.a
# left_join()	SELECT * FROM x LEFT JOIN y ON x.a = y.a
# right_join()	SELECT * FROM x RIGHT JOIN y ON x.a = y.a
# full_join()	SELECT * FROM x FULL JOIN y ON x.a = y.a
# semi_join()	SELECT * FROM x WHERE EXISTS (SELECT 1 FROM y WHERE x.a = y.a)
# anti_join()	SELECT * FROM x WHERE NOT EXISTS (SELECT 1 FROM y WHERE x.a = y.a)
# intersect(x, y)	SELECT * FROM x INTERSECT SELECT * FROM y
# union(x, y)	SELECT * FROM x UNION SELECT * FROM y
# setdiff(x, y)	SELECT * FROM x EXCEPT SELECT * FROM y
# 

test_that("everthing is ok", {
  testthat::skip_on_cran()
  x1 <- poly1
  
  x1 %>% filter(NAME == "Australia")
  x1 %>% filter(POP2005 > 2e6)
  x1 %>% filter(grepl("Aust", NAME))
  x1 %>% slice(c(100, 200))
  
  x1 %>% arrange(AREA)
  x1 %>% dplyr::select(NAME, POP2005, AREA)
  x1 %>% rename(Country = NAME, Population = POP2005)
  x1 %>% distinct(AREA, .keep_all = TRUE)
  x1 %>% mutate(AREA = REGION * 2)
  x1 %>% transmute(NAME = gsub("^A", "Z", NAME))
  x1 %>% summarize(a = 'POP2005')
  
  #x1 %>% group_by(REGION)
  #x1 %>% summarize(a = POP2005)
})