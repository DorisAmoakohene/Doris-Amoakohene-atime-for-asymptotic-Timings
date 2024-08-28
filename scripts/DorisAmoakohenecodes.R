

library(atime)
library(ggplot2)
library(data.table)
library(directlabels)
library(dplyr)

#showing the best fit asymptotic time complexity for each linear and constant timings

(subject.size.vec <- unique(as.integer(10^seq(0,9,l=100))))
atime.list <- atime::atime(
  setup={
    set.seed(123)
    subject <- paste(rep("a", N), collapse="")
    pattern <- paste(rep(c("a?", "a"), each=N), collapse="")
  },
  constant.replacement=gsub("a",subject,subject),
  linear.replacement=gsub("a","linear size replacement",subject),
  seconds.limit=3,
  times=20, 
  N=subject.size.vec)
(best.list.R <- atime::references_best(atime.list))


p <- ggplot(best.list.R$measurements, aes(x = N, y = median, group = expr.name, colour = expr.name)) +
  geom_line() +
  geom_ribbon(aes(ymin = min, ymax = max, fill = expr.name), alpha = 0.5, colour = NA) +
  scale_x_log10("N = number of rows in the dataset", limits = c(10, 1e8), breaks = 10^seq(1, 7)) +
  theme(
    text = element_text(size = 20),
    axis.text = element_text(size = 15),
    axis.title = element_text(size = 15)
  )+
  scale_y_log10("Computational Time (Seconds)") +
  labs(x = "N = number of rows in the dataset", y = "Computational Time (Seconds)") +
  theme(legend.position = "none")

p <- p + geom_dl(aes(label = gsub(".replacement", "", expr.name)), method = list(dl.combine("last.points"), cex = 1.5))

ggsave("best.list.R.png", plot = p, width = 8, height = 5, unit = "in", dpi = 600)



#Comparing different functions for reading a csv file

read.colors <- c(
  "readr::read_csv"="#9970AB",
  "data.table::fread"="#D6604D",
  "utils::read.csv" = "deepskyblue")

n.rows <- 100
seconds.limit <- 5


atime.read.vary.cols <- atime::atime(
  N=as.integer(10^seq(2, 6, by=0.5)),
  setup={
    set.seed(1)
    input.vec <- rnorm(n.rows*N)
    input.mat <- matrix(input.vec, n.rows, N)
    input.df <- data.frame(input.mat)
    input.csv <- tempfile()
    fwrite(input.df, input.csv)
  },
  seconds.limit = seconds.limit,
  "data.table::fread"={
    data.table::fread(input.csv, showProgress = FALSE)
  },
  "readr::read_csv"={
    readr::read_csv(input.csv, progress = FALSE, show_col_types = FALSE, lazy=TRUE)
  },
  "utils::read.csv"=utils::read.csv(input.csv))




# Interpolate to find the exact N values where computation time is 5 seconds
five_sec_N <- atime.read.vary.cols$measurements %>%
  group_by(expr.name) %>%
  summarize(N = approx(x = median, y = N, xout = 5)$y)

# Create the plot
png("gg.read.3.png", res = 300, width = 12, height = 8, unit = "in")
gg.read.3 <- ggplot() +
  geom_line(data = atime.read.vary.cols$measurements, aes(x = N, y = median, color = expr.name, group = expr.name)) +
  geom_ribbon(aes(x = N, ymin = min, ymax = max, fill = expr.name), data = atime.read.vary.cols$measurements, alpha = 0.5) +
  geom_hline(yintercept = 5, linetype = "solid", color = "black") +
  annotate("text", x = 10^2, y = 5, label = "seconds = 5", color = "black", size = 7, vjust = 1, hjust = 0.2) +
  theme(
    text = element_text(size = 20),
    axis.text = element_text(size = 20),
    axis.title = element_text(size = 20)
  ) +
  scale_x_log10("N = number of columns to read") +
  scale_y_log10("Computation time (seconds)") +
  scale_fill_manual(values = read.colors) +
  scale_color_manual(values = read.colors)

# Adjust the position of the direct labels
directlabels::direct.label(gg.read.3, list(cex = 1.5, "top.polygons", method = "smart.grid"))

dev.off()





# Define the colors for each expr.name value
color_map <- c(
  "readr::read_csv"="#9970AB",
  "data.table::fread"="#D6604D",
  "utils::read.csv" = "deepskyblue")

png("gg.read.3.png", res = 300, width = 12, height = 9, unit = "in")
gg.read.3 +
  geom_label(data = five_sec_N,
             aes(x = N, y = 5, label = paste(expr.name, "\nN =", round(N, 2)), fill = expr.name),
             vjust = -1, size = 6) +
  scale_fill_manual(values = color_map)+
  theme(legend.position = "none")
# Adjust the position of the direct labels
directlabels::direct.label(gg.read.3, list(cex = 1.5, "top.polygons", method = "smart.grid"))

dev.off()






#Performance Testing:

tdir <- tempfile()
dir.create(tdir)
git2r::clone("https://github.com/Rdatatable/data.table", tdir)

##Performance Test case with two code branches: fast and slow

atime.colors.2 <- c(
  Slow="#E6AB02",
  Fast="#A6761D"
)

atime.list.5427 <- atime::atime_versions(
  pkg.path=tdir,
  pkg.edit.fun=function(old.Package, new.Package, sha, new.pkg.path){
    pkg_find_replace <- function(glob, FIND, REPLACE){
      atime::glob_find_replace(file.path(new.pkg.path, glob), FIND, REPLACE)
    }
    Package_regex <- gsub(".", "_?", old.Package, fixed=TRUE)
    Package_ <- gsub(".", "_", old.Package, fixed=TRUE)
    new.Package_ <- paste0(Package_, "_", sha)
    pkg_find_replace(
      "DESCRIPTION", 
      paste0("Package:\\s+", old.Package),
      paste("Package:", new.Package))
    pkg_find_replace(
      file.path("src","Makevars.*in"),
      Package_regex,
      new.Package_)
    pkg_find_replace(
      file.path("R", "onLoad.R"),
      Package_regex,
      new.Package_)
    pkg_find_replace(
      file.path("R", "onLoad.R"),
      sprintf('packageVersion\\("%s"\\)', old.Package),
      sprintf('packageVersion\\("%s"\\)', new.Package))
    pkg_find_replace(
      file.path("src", "init.c"),
      paste0("R_init_", Package_regex),
      paste0("R_init_", gsub("[.]", "_", new.Package_)))
    pkg_find_replace(
      "NAMESPACE",
      sprintf('useDynLib\\("?%s"?', Package_regex),
      paste0('useDynLib(', new.Package_))
  },
  N=10^seq(1,7, by = 0.25),
  setup={ 
    DT = replicate(N, 1, simplify = FALSE)
  },
  expr=data.table:::setDT(DT),
  "Slow"= "c4a2085e35689a108d67dacb2f8261e4964d7e12", #Parent of the first commit in the PR that fixes the issue(https://github.com/Rdatatable/data.table/commit/7cc4da4c1c8e568f655ab5167922dcdb75953801),
  
  "Fast"="1872f473b20fdcddc5c1b35d79fe9229cd9a1d15")#last commit in the PR that fixes the issue (https://github.com/Rdatatable/data.table/pull/5427/commits)


png("atime.list.5427.png",res = 600, width = 5, height = 3, unit = "in")
atime.list.5427 = ggplot()+
  geom_line(aes(x = N, y = median, group = expr.name, colour = expr.name), data =  atime.list.5427$measurements)+
  geom_ribbon(aes(x = N, ymin = min, ymax = max, fill = expr.name), data = atime.list.5427$measurements, alpha = 0.5 )+
  scale_x_log10("N = number of rows",limits = c(1e1, 1e8), breaks = 10^seq(1,8))+
  scale_y_log10("Computational Time (Seconds)")+
  scale_fill_manual(values=atime.colors.2)+
  scale_color_manual(values=atime.colors.2)
directlabels::direct.label(atime.list.5427, list(cex = 1, "right.polygons"))
dev.off()


##Performance Test case with three code branches: Regression, Fixed and Before:

atime.colors.1 <- c(#RColorBrewer::brewer.pal(7, "Dark2")
  Before="#66A61E",
  Regression="#E6AB02", 
  Fixed="#A6761D"
)


atime.list.4200 <- atime::atime_versions(
  pkg.path=tdir,
  pkg.edit.fun=function(old.Package, new.Package, sha, new.pkg.path){
    pkg_find_replace <- function(glob, FIND, REPLACE){
      atime::glob_find_replace(file.path(new.pkg.path, glob), FIND, REPLACE)
    }
    Package_regex <- gsub(".", "_?", old.Package, fixed=TRUE)
    Package_ <- gsub(".", "_", old.Package, fixed=TRUE)
    new.Package_ <- paste0(Package_, "_", sha)
    pkg_find_replace(
      "DESCRIPTION", 
      paste0("Package:\\s+", old.Package),
      paste("Package:", new.Package))
    pkg_find_replace(
      file.path("src","Makevars.*in"),
      Package_regex,
      new.Package_)
    pkg_find_replace(
      file.path("R", "onLoad.R"),
      Package_regex,
      new.Package_)
    pkg_find_replace(
      file.path("R", "onLoad.R"),
      sprintf('packageVersion\\("%s"\\)', old.Package),
      sprintf('packageVersion\\("%s"\\)', new.Package))
    pkg_find_replace(
      file.path("src", "init.c"),
      paste0("R_init_", Package_regex),
      paste0("R_init_", gsub("[.]", "_", new.Package_)))
    pkg_find_replace(
      "NAMESPACE",
      sprintf('useDynLib\\("?%s"?', Package_regex),
      paste0('useDynLib(', new.Package_))
  },
  N=10^seq(1,7,by = 0.25),
  setup={ 
    set.seed(108)
    d <- data.table(
      id3 = sample(c(seq.int(N*0.9), sample(N*0.9, N*0.1, TRUE))),
      v1 = sample(5L, N, TRUE),
      v2 = sample(5L, N, TRUE))
  },
  expr=data.table:::`[.data.table`(d, , (max(v1)-min(v2)), by = id3),
  "Before"="793f8545c363d222de18ac892bc7abb80154e724",#parent of the PR that introduced the regression(https://github.com/Rdatatable/data.table/commit/4aadde8f5a51cd7c8f3889964e7280432ec65bbc) as stated here (https://github.com/Rdatatable/data.table/issues/4200#issuecomment-646111420) https://github.com/Rdatatable/data.table/commit/793f8545c363d222de18ac892bc7abb80154e724
  "Regression"="c152ced0e5799acee1589910c69c1a2c6586b95d", #parent of the first commit in the PR (https://github.com/Rdatatable/data.table/commit/15f0598b9828d3af2eb8ddc9b38e0356f42afe4f)
  "Fixed"="f750448a2efcd258b3aba57136ee6a95ce56b302")#second commit in the PR that fixes the regression(https://github.com/Rdatatable/data.table/pull/4558/commits)

png("atime.list.4200.png",res = 600, width = 5, height = 3, unit = "in")
atime.list.4200 = ggplot()+
  geom_line(aes(x = N, y = median, group = expr.name, colour = expr.name), data =  atime.list.4200$measurements)+
  geom_ribbon(aes(x = N, ymin = min, ymax = max, fill = expr.name), data = atime.list.4200$measurements, alpha = 0.5 )+
  scale_x_log10("N = number of rows",limits = c(1e1, 1e5), breaks = 10^seq(1,7))+
  scale_y_log10("Computational Time (Seconds)")+
  scale_fill_manual(values=atime.colors.1)+
  scale_color_manual(values=atime.colors.1)
directlabels::direct.label(atime.list.4200, list(cex = 1, "right.polygons"))
dev.off()


