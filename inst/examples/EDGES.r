

#' Segment indexing for a path. 
#' 
#' \code{n2edge) returns the paired indexing for a sequential path of \code{n} steps. 
#' \code{path2edge} returns the indexes from a sequential path, indexed by \code{n2edge}
#' \code{edgetab} builds a data frame of vertex indexes and edge identifier
#' \code{readgris} extracts a fleshed out vertex table with optional object table for subset
#' @param nx number of points in the path
#' @rdname spbabel-internal
#' @return index of integers defining each segment or edge
n2edge <- function(nx) {
  head(rep(1:2, nx) + rep(seq(nx)-1, each = 2), -2)
}
#' @rdname spbabel-internal
path2edge <- function(x)  x[n2edge(length(x))]
#' @rdname spbabel-internal
edgetab <- function(x) {
  closed <- path2edge(x); 
  closed <- c(closed, tail(closed, 1), head(closed, 1))
  data_frame(.vx0 = closed, .edg = rep(head(seq(length(x) + 1), -1), each = 2))
}
#' @rdname spbabel-internal
readgris <- function(db, data) {
  if (missing(db)) db <- src_sqlite(system.file("extdata", "gworld.sqlite3", package = "spbabel"))
  if (missing(data)) data <- tbl(db, "o")  
  data %>% dplyr::select(.ob0) %>% 
    inner_join(tbl(db, "b"), ".ob0") %>% 
    inner_join(tbl(db, "bXv"), ".br0") %>% 
    inner_join(tbl(db, "v", ".vx0")) %>% 
    arrange(.br0, .br_order)  %>%  collect() %>% #filter(y < -39.3 & y > -45) %>% 
    transmute(x_ = x, y_ = y, object_ = .br0, branch_ = .br0, island_ = .h0, vertex_ = .vx0)
  
}
library(raster)
library(dplyr)
library(RTriangle)
library(spbabel)

#getData("SRTM", lon = mean(verts$x_), lat = mean(verts$y_))
#dem <- raster("srtm_35_11.tif")
dem <- raster("srtm_38_03.tif")

## normalized map

db <- src_sqlite(system.file("extdata", "gworld.sqlite3", package = "spbabel"))
aa <- 
  tbl(db, "o") %>% dplyr::filter(NAME %in% c("France", "Switzerland", "Italy"))
verts <- readgris(db, aa)

plot(spFromTable(verts), col = sample(rainbow(length(unique(verts$object_)), alpha = 0.5)), add = FALSE)

## once we have the gris format, we only need the branches to figure out edges
edge <- bind_rows(lapply(split(verts, verts$branch_), function(x) edgetab(x$vertex_)))
vtx <- verts %>% 
  left_join(edge, c("vertex_" = ".vx0"), copy = TRUE) %>% 
  filter(!is.na(.edg)) %>% 
  dplyr::select(x_, y_, vertex_) %>% 
  collect() %>% distinct(x_, y_) %>% mutate(rownum = row_number())
#edge %>% inner_join(vtx) %>% select(rownum)

ps <- pslg(P = vtx  %>% dplyr::select(x_, y_) %>%  as.matrix(), 
           S = matrix((edge %>% inner_join(vtx, c(".vx0" = "vertex_")) %>% dplyr::select(rownum))$rownum, ncol = 2, byrow = TRUE))

tri <- triangulate(ps, a = 0.0005)

tet <- rgl::tetrahedron3d()
tet$vb <- t(cbind(tri$P, extract(dem, tri$P), 1))
tet$vb[3,is.na(tet$vb[3,])] <- 0
tet$it <- t(tri$T)
rgl::shade3d(tet, col = "white")
rgl::aspect3d(1, 1, 1e-2)

ee <- edge  %>% left_join(verts, c(".vx0" = "vertex_"))
rgl::segments3d(ee$x_, ee$y_, 0, lwd = 6, line_antialias = TRUE)
