library(RColorBrewer)
library(mefa4)
ROOT <- "e:/peter/bam/Apr2016"
ROOT2 <- "e:/peter/bam/pred-2015"
ROOT3 <- "e:/peter/bam/pred-2016"
source("~/repos/bamanalytics/R/makingsense_functions.R")
#source("~/repos/bamanalytics/R/analysis_mods.R")

PROJECT <- "bam"
spp <- "CAWA"
Date <- "2016-04-18"

Stage <- 6 # which(names(mods) == "Clim")
# 2001, 2005, 2009, 2013
BASE_YEAR <- 2012

e <- new.env()
load(file.path(ROOT, "out", "data", "pack_2016-04-18.Rdata"), envir=e)
mods <- e$mods
Terms <- getTerms(e$mods, "list")
setdiff(Terms, colnames(e$DAT))
xn <- e$DAT[1:500,Terms]
Xn <- model.matrix(getTerms(mods, "formula"), xn)
colnames(Xn) <- fixNames(colnames(Xn))
rm(e)

load(file.path(ROOT, "out", "results", paste0(PROJECT, "_", spp, "_", Date, ".Rdata")))
cat(100 * sum(getOK(res)) / length(res), "% OK\n", sep="")
est <- getEst(res, stage = Stage, X=Xn)

regs <- gsub(".Rdata", "",
    gsub("pgdat-", "", list.files(file.path(ROOT2, "chunks3"))))

#regi <- "6_AB"
for (regi in regs) {

cat(regi, "\n");flush.console()

load(file.path(ROOT2, "chunks3", paste0("pgdat-", regi, ".Rdata")))
gc()

dat$HAB <- dat$HAB_NALC2
dat$HABTR <- dat$HAB_NALC1
dat$HGT[dat$HAB %in% c("Agr","Barren","Devel","Grass", "Shrub")] <- 0
dat$HGT2 <- dat$HGT^2
dat$HGT05 <- dat$HGT^0.5

dat$ROAD <- 0L

## YR
dat$YR <- BASE_YEAR - 2001

## disturbance
dat$YearFire[is.na(dat$YearFire)] <- BASE_YEAR - 200
dat$YearLoss[is.na(dat$YearLoss)] <- BASE_YEAR - 200

## years since fire 
dat$YSF <- BASE_YEAR - dat$YearFire
dat$YSF[dat$YSF < 0] <- 200
## years since loss
dat$YSL <- BASE_YEAR - dat$YearLoss
dat$YSL[dat$YSL < 0] <- 200
## years since most recent burn or loss
dat$YSD <- pmin(dat$YSF, dat$YSL)

## cut at 10 yrs
dat$BRN <- ifelse(dat$YSF <= 10, 1L, 0L)
dat$LSS <- ifelse(dat$YSL <= 10, 1L, 0L)
dat$LSS[dat$YEAR < 2000] <- NA
dat$DTB <- ifelse(dat$YSD <= 10, 1L, 0L)
dat$DTB[dat$YEAR < 2000] <- NA

## refining years since variables
AGEMAX <- 50
dat$YSD <- pmax(0, 1 - (dat$YSD / AGEMAX))
dat$YSF <- pmax(0, 1 - (dat$YSF / AGEMAX))
dat$YSL <- pmax(0, 1 - (dat$YSL / AGEMAX))

dat0 <- dat[rowSums(is.na(dat)) == 0,]
Xn0 <- model.matrix(getTerms(mods[1:Stage], "formula"), dat0)
colnames(Xn0) <- fixNames(colnames(Xn0))
NR <- nrow(Xn0)

mu0 <- matrix(0, NR, 240)
if (NR > 0) {
    for (j in 1:nrow(est)) {
        mu0[,j] <- drop(Xn0 %*% est[j,colnames(Xn0)])
    }
    lam <- lamfun(mu0)
    rownames(lam) <- rownames(dat0)
    rm(mu0, dat0, Xn0)
    attr(lam, "spp") <- spp
    attr(lam, "stage") <- Stage
    attr(lam, "base-year") <- BASE_YEAR
    attr(lam, "bcr-jurs") <- regi
} else {
    lam <- NULL
}
gc()

fout <- file.path(ROOT3, "species", spp, 
    paste0(spp, "-", Stage, "-", BASE_YEAR, "-", regi, "-", Date, ".Rdata"))
save(lam, file=fout)
rm(lam)

}




## mapping starts here -----------------------------

library(RColorBrewer)
library(mefa4)
ROOT <- "e:/peter/bam/Apr2016"
ROOT2 <- "e:/peter/bam/pred-2015"
ROOT3 <- "e:/peter/bam/pred-2016"
load(file.path("e:/peter/bam/pred-2015", "pg-main-NALConly.Rdata"))
XY <- as.matrix(x[,c("POINT_X","POINT_Y")])
XYb <- as.matrix(x[!is.na(x$Brandt),c("POINT_X","POINT_Y")])
rm(x)
gc()

source("~/repos/bamanalytics/R/makingsense_functions.R")
#source("~/repos/bamanalytics/R/analysis_mods.R")
#load(file.path(ROOT, "out", "analysis_package_YYSS.Rdata"))
#load(file.path(ROOT2, "XYeosd.Rdata"))
#load(file.path(ROOT2, "XYfull.Rdata"))

PROJECT <- "bam"
spp <- "CAWA"
Date <- "2016-04-18"

Stage <- 6 # which(names(mods) == "Clim")
# 2001, 2005, 2009, 2013
BASE_YEAR <- 2012

#xy1 <- XYSS[YYSS[,spp] > 0, c("Xcl","Ycl")]

ttt <- list()
brr <- list()

gc()
fo <- paste0(spp, "-", Stage, "-", BASE_YEAR, "-", Date)
cat(fo, "\n");flush.console()

e <- new.env()
load(file.path(ROOT, "out", "data", "pack_2016-04-18.Rdata"), envir=e)
mods <- e$mods
Terms <- getTerms(e$mods, "list")
setdiff(Terms, colnames(e$DAT))
xn <- e$DAT[1:500,Terms]
Xn <- model.matrix(getTerms(mods, "formula"), xn)
colnames(Xn) <- fixNames(colnames(Xn))
rm(e)

load(file.path(ROOT, "out", "results", paste0(PROJECT, "_", spp, "_", Date, ".Rdata")))
cat(100 * sum(getOK(res)) / length(res), "% OK\n", sep="")
est <- getEst(res, stage = Stage, X=Xn)

#regs <- sort(gsub(".Rdata", "",
#    gsub("pgdat-", "", list.files(file.path(ROOT2, "chunks3")))))
regsAll <- c(
    "2_AK", 
    "3_AK", "3_MB", "3_NL", "3_NT", "3_NU", "3_QC", "3_YK", 
    "4_AK", "4_BC", "4_NT", "4_YK", 
    "5_AK", "5_BC", "5_CA", "5_OR", "5_WA", "5_YK", 
    "6_AB", "6_BC", "6_MB", "6_MN", "6_NT", "6_NU", "6_SK", "6_YK", 
    "7_AB", "7_MB", "7_NL", "7_NT", "7_NU", "7_ON", "7_QC", "7_SK", 
    "8_AB", "8_MB", "8_NL", "8_ON", "8_QC", "8_SK", 
    "9_BC", "9_CA", "9_ID", "9_NV", "9_OR", "9_UT", "9_WA", "9_WY",
    "10_AB", "10_BC", "10_ID", "10_MT", "10_OR", "10_UT", "10_WA", "10_WY", 
    "11_AB", "11_IA", "11_MB", "11_MN", "11_MT", "11_ND", "11_NE", "11_SD", "11_SK", 
    "12_MB", "12_MI", "12_MN", "12_ON", "12_QC", "12_WI", 
    "13_MI", "13_NY", "13_OH", "13_ON", "13_PA", "13_QC", "13_VT", 
    "14_CT", "14_MA", "14_ME", "14_NB", "14_NH", "14_NS", "14_NY", "14_PE", "14_QC", "14_VT", 
    "23_IA", "23_IL", "23_IN", "23_MI", "23_MN", "23_OH", "23_WI")
regs <- c(
    "2_AK", 
    "4_AK", "4_BC", "4_NT", "4_YK", 
    "5_AK", "5_BC", "5_YK", #"5_CA", "5_OR", "5_WA", 
    "6_AB", "6_BC", "6_MB", "6_MN", "6_NT", "6_NU", "6_SK", "6_YK", 
    "7_AB", "7_MB", "7_NL", "7_NT", "7_NU", "7_ON", "7_QC", "7_SK", 
    "8_AB", "8_MB", "8_NL", "8_ON", "8_QC", "8_SK", 
    "9_BC", #"9_CA", "9_ID", "9_NV", "9_OR", "9_UT", "9_WA", "9_WY",
    "10_AB", "10_BC", #"10_ID", "10_MT", "10_OR", "10_UT", "10_WA", "10_WY", 
    "11_AB", "11_MB", "11_MN", "11_SK", # ???
    "12_MB", "12_MI", "12_MN", "12_ON", "12_QC", "12_WI", 
    "13_MI", "13_NY", "13_OH", "13_ON", "13_PA", "13_QC", "13_VT", 
    "14_CT", "14_MA", "14_ME", "14_NB", "14_NH", "14_NS", "14_NY", "14_PE", "14_QC", "14_VT", 
    "23_IA", "23_IL", "23_IN", "23_MI", "23_MN", "23_OH", "23_WI")

fl <- paste0(spp, "-", Stage, "-", BASE_YEAR, "-", regsAll, "-", Date, ".Rdata")

is_null <- integer(length(fl))
names(is_null) <- fl
load(file.path(ROOT3, "species", spp, fl[1]))
if (is.null(lam)) {
    is_null[1] <- 1L
} else {
    plam <- lam
    tlam <- attr(lam, "total")
}
for (fn in fl[-1]) {
    cat("loading", fn, "\n");flush.console()
    load(file.path(ROOT3, "species", spp, fn))
    if (is.null(lam)) {
        is_null[fn] <- 1L
    } else {
        plam <- rbind(plam, lam)
        tlam <- rbind(tlam, attr(lam, "total"))
    }
}
rownames(tlam) <- regs[is_null==0]
dim(plam)
sum(duplicated(rownames(plam)))

if (TRUE) {
    q <- quantile(plam[,"Mean"], 0.99)
    plam[plam[,"Mean"] > q,"Mean"] <- q

    q <- quantile(plam[,"Median"], 0.99)
    plam[plam[,"Median"] > q,"Median"] <- q
}

rn <- intersect(rownames(plam), rownames(XY))
#compare_sets(rownames(plam), rownames(XY))
XY2 <- XY[rn,]
#x <- plam[rn,"Mean"]
x <- plam[rn,"Median"]
probs <- c(0, 0.05, 0.1, 0.25, 0.5, 1)
TEXT <- paste0(100*probs[-length(probs)], "-", 100*probs[-1], "%")
Col <- rev(brewer.pal(5, "RdYlBu"))
br <- Lc_quantile(x, probs=probs, type="L")
if (!is.finite(br[length(br)]))
    br[length(br)] <- 1.01* max(x, na.rm=TRUE)
brr[[fo]] <- br
ttt[[fo]] <- tlam


#e <- new.env()
#load("e:/peter/bam/Apr2016/out/data/pack_2016-04-18.Rdata", envir=e)
#with(e$DAT, table(JURS, xBCR))
#with(e$DAT, plot(X, Y, pch=".", col=as.integer(JURS)))

png(file.path(ROOT3, "maps", spp, paste0("x2.png")), width = 2000, height = 1000)
op <- par(mfrow=c(1,1), mar=c(1,1,1,1)+0.1)
plot(XY, col = "lightgrey", pch=".", ann=FALSE, axes=FALSE)
points(XY2, col = 4, pch=".")
par(op)
dev.off()


png(file.path(ROOT3, "maps", spp, paste0(fo, "-median.png")), 
    width = 2000, height = 1000)
op <- par(mfrow=c(1,1), mar=c(1,1,1,1)+0.1)

zval <- if (length(unique(round(br,10))) < 5)
    rep(1, length(x)) else as.integer(cut(x, breaks=br))
plot(XY2, col = Col[zval], pch=".",
    ann=FALSE, axes=FALSE)
legend("topright", bty = "n", legend=rev(TEXT), 
    fill=rev(Col), border=1, cex=3, 
    #title=paste(spp, "mean abundance"))
    title=paste(spp, "median abundance"))
par(op)
dev.off()

br <- c(0, 0.4, 0.8, 1.2, 1.6, Inf)
Col <- rev(brewer.pal(5, "RdYlGn"))
TEXT <- paste0(100*br[-length(br)], "-", 100*br[-1], "%")
TEXT[length(TEXT)] <- paste0(">", 100*br[length(br)-1], "%") 
#CoV <- plam[,"SD"] / plam[,"Mean"]
CoV <- plam[,"IQR"] / plam[,"Median"]
zval <- cut(CoV, breaks=br)
if (ids$SEXT[fid] == "nam") {
    plot(XYfull[rownames(plam),], col = Col[zval], pch=".",
        ann=FALSE, axes=FALSE)
} else {
    plot(XYeosd[rownames(plam),], col = Col[zval], pch=".",
        ann=FALSE, axes=FALSE)
}
points(xy1, pch=19, cex=2)
legend("topright", bty = "n", legend=rev(TEXT), 
    fill=rev(Col), border=1, cex=3, 
    #title=paste(spp, "SD / mean"))
    title=paste(spp, "IQR / median"))


tlam <- data.frame(t(tlam))
write.csv(tlam, row.names=FALSE,
    file=file.path(ROOT2, "species", "cawa-nmbca-tabs", paste0("byregion-", fo, ".csv")))
plam <- data.frame(id=rownames(plam), median=plam[,"Median"], cov=CoV)
write.csv(plam, row.names=FALSE,
    file=file.path(ROOT2, "species", "cawa-nmbca-tabs", paste0("bypoint-", fo, ".csv")))


rm(plam)

## brr: list of Lc based breaks
## ttt: list of BCR/prov x B matrices
#save(brr, ttt, file=file.path(ROOT2, "species", "tlam-CAWA.Rdata"))

load(file.path(ROOT2, "species", "tlam-CAWA.Rdata"))

f <- function(x) {
    q <- unname(quantile(x, c(0.5, 0.05, 0.95)))
    c(Mean=mean(x), SD=sd(x), Median=q[1], LCL90=q[2], UCL90=q[3], IQR=q[3]-q[2])
}
for (i in 1:length(ttt)) {

tmp <- t(apply(ttt[[i]], 1, f))
write.csv(tmp, row.names=TRUE,
    file=file.path(ROOT2, "species", "cawa-nmbca-tabs", 
    paste0("summary-by-region-", names(ttt)[i], ".csv")))
}



## dealing with outliers
ttt2 <- ttt
for (i in 1:16) {
    tmp <- ttt[[i]]
    if (any(tmp > 10^10)) {
        for (j in 1:nrow(tmp)) {
            vv <- tmp[j,]
            vv <- vv[is.finite(vv)]
            q <- quantile(vv, 0.99)
            cat(j, q, "\n")
            tmp[j, tmp[j,] > q] <- q
        }
    }
    ttt2[[i]] <- tmp
}

t(sapply(ttt, function(z) 
        c(mean=mean(colSums(z)/10^6), median=median(colSums(z)/10^6))))
t(sapply(ttt2, function(z) 
        c(mean=mean(colSums(z)/10^6), median=median(colSums(z)/10^6))))


df <- data.frame(ids[rep(1:6, each=2),1:3], 
    Year=c(2002, 2012),
    t(sapply(ttt[1:12], function(z) 
        c(mean=mean(colSums(z)/10^6), median=median(colSums(z)/10^6)))))
df$change <- NA
for (i in 1:6) {
    N0 <- df$median[i*2-1]
    N10 <- df$median[i*2]
    df$change[i*2] <- 100 * ((N10/N0)^(1/10) - 1)
}

write.csv(df, file=file.path(ROOT2, "species", "popsize.csv"))

pe <- data.frame(ids[1:6,1:3],
    Year=BASE_YEAR,
    t(sapply(ttt, function(z) 
        c(mean=mean(colSums(z)/10^6), median=median(colSums(z)/10^6)))))
save(ttt, file=file.path(ROOT, "out", "figs", "nmbca2", 
    paste0(paste0("popsize-", spp, "-", Stage, "-", BASE_YEAR, "-", Date), ".Rdata")))

## 2003

pe03 <- structure(list(TEXT = structure(c(1L, 2L, 1L, 2L, 1L, 2L), .Label = c("gfw", 
    "fre"), class = "factor"), SEXT = structure(c(1L, 1L, 1L, 1L, 
    1L, 1L), .Label = c("can", "nam"), class = "factor"), LCTU = structure(c(1L, 
    1L, 2L, 2L, 3L, 3L), .Label = c("nlc", "lcc", "eos"), class = "factor"), 
        Year = c(2003, 2003, 2003, 2003, 2003, 2003), mean = c(7.04675889420143, 
        8.1948604617475, 7.30885952161788, 8.12954353917993, 7.32127463952691, 
        8.04625186575813), median = c(7.03908748814014, 7.90960556092234, 
        7.28424257344771, 7.97434394721777, 7.29854788856675, 7.70893150271355
        )), .Names = c("TEXT", "SEXT", "LCTU", "Year", "mean", "median"
    ), row.names = c(NA, 6L), class = "data.frame")

pe13 <- structure(list(TEXT = structure(c(1L, 2L, 1L, 2L, 1L, 2L), .Label = c("gfw", 
    "fre"), class = "factor"), SEXT = structure(c(1L, 1L, 1L, 1L, 
    1L, 1L), .Label = c("can", "nam"), class = "factor"), LCTU = structure(c(1L, 
    1L, 2L, 2L, 3L, 3L), .Label = c("nlc", "lcc", "eos"), class = "factor"), 
        Year = c(2013, 2013, 2013, 2013, 2013, 2013), mean = c(7.03823934905092, 
        8.2201686110189, 7.29573582539286, 8.15710339698905, 7.2890423740622, 
        8.0574300369338), median = c(7.02512525548913, 7.93361330635701, 
        7.27357416838527, 7.98576510700306, 7.2667175762312, 7.70826606796275
        )), .Names = c("TEXT", "SEXT", "LCTU", "Year", "mean", "median"
    ), row.names = c(NA, 6L), class = "data.frame")






## -- old

spp <- "CAWA"
wid <- 1
Stage <- 6
BASE_YEAR <- 2015
regs <- gsub(".Rdata", "",
    gsub("pgdat-", "", list.files(file.path(ROOT2, "chunks"))))

xy1 <- XYSS[YYSS[,spp] > 0, c("Xcl","Ycl")]

fl <- paste0(paste(spp, wid, Stage, BASE_YEAR, regs, sep="-"), ".Rdata")
load(file.path(ROOT2, "species", paste0(spp, "-ver3"), fl[1]))
plam <- lam
tlam <- attr(lam, "total")
for (fn in fl[-1]) {
    cat("loading", fn, "\n");flush.console()
    load(file.path(ROOT2, "species", paste0(spp, "-ver3"), fn))
    plam <- rbind(plam, lam)
    tlam <- rbind(tlam, attr(lam, "total"))
}
dim(plam)
sum(duplicated(rownames(plam)))

hist(colSums(tlam)/10^6, col=3)
sum(tlam[,1])/10^6
median(colSums(tlam)/10^6)
mean(colSums(tlam)/10^6)


plotfun <- function(plam, what="Median") {
    z <- plam[,what]
    #z <- plam[,"IQR"]/plam[,"Median"]
    Col <- rev(brewer.pal(10, "RdBu"))
    cz <- cut(z, breaks = c(min(z)-1, quantile(z, seq(0.1, 1, 0.1))))
    plot(XYeosd[rownames(plam),], col = Col[cz], pch=".")
    invisible(NULL)
}

plotfun(z)

z <- dat1$HAB
Col <- brewer.pal(9, "Set3")
plot(dat[,2:3], col = Col[z], pch=".")

hs <- rowSums(pg4x4$nalc[rownames(dat0), c("Decid", "Mixed")])
plot(hs, aa)
table(unlist(lapply(sres$nalc, "[[", "hi")))







png(file.path(ROOT, "out", "figs", "CAWA-ver3-2015.png"), width = 2000, height = 2000)
op <- par(mfrow=c(2,1), mar=c(1,1,1,1)+0.1)

library(RColorBrewer)
x <- plam[,"Mean"]
probs <- c(0, 0.05, 0.1, 0.25, 0.5, 1)
TEXT <- paste0(100*probs[-length(probs)], "-", 100*probs[-1], "%")
Col <- rev(brewer.pal(5, "RdYlBu"))
br <- Lc_quantile(x, probs=probs, type="L")
zval <- if (length(unique(round(br,10))) < 5)
    rep(1, length(x)) else as.integer(cut(x, breaks=br))
plot(XYeosd[rownames(plam),], col = Col[zval], pch=".",
    ann=FALSE, axes=FALSE)
points(xy1, pch=19, cex=2)


br <- c(0, 0.2, 0.4, 0.6, 0.8, 1, 1.2, 1.4, 1.6, 1.8, Inf)
Col <- rev(brewer.pal(10, "RdYlGn"))
CoV <- plam[,"SD"] / plam[,"Mean"]
zval <- cut(CoV, breaks=br)
plot(XYeosd[rownames(plam),], col = Col[zval], pch=".",
    ann=FALSE, axes=FALSE)
points(xy1, pch=19, cex=2)

par(op)
dev.off()

yrs <- c(2001, 2005, 2009, 2013)
gfw <- list()
for (BASE_YEAR in yrs) {
    fl <- paste0(paste(spp, wid, Stage, BASE_YEAR, regs, sep="-"), ".Rdata")
    load(file.path(ROOT2, "species", spp, fl[1]))
    plam <- lam
    tlam <- attr(lam, "total")
    for (fn in fl[-1]) {
        cat("loading", fn, "\n");flush.console()
        load(file.path(ROOT2, "species", spp, fn))
        plam <- rbind(plam, lam)
        tlam <- rbind(tlam, attr(lam, "total"))
    }
    gfw[[as.character(BASE_YEAR)]] <- tlam
}

hist(colSums(tlam)/10^6, col=3)
sum(tlam[,1])/10^6
median(colSums(tlam)/10^6)

ps <- sapply(gfw, function(z) {
    tmp <- colSums(z)/10^6
    c(Mean=mean(tmp), quantile(tmp, c(0.025, 0.975)))
    })

ps <- rbind(ps, Percent=(100 * ps[1,] / ps[1,1]) - 100)
ps <- rbind(ps, Decadal=10*ps[4,]/c(yrs-yrs[1]))


#spp <- "CAWA"

getDistPred <- function(spp) {
    xy1 <- XYSS[YYSS[,spp] > 0, c("Xcl","Ycl")]
    fd <- function(i) {
        xy <- XYeosd[i, ]
        min(sqrt((xy[1] - xy1[,1])^2 + (xy[2] - xy1[,2])^2)) / 1000
    }
    pbsapply(seq_len(nrow(XYeosd)), fd)
}

dp_cawa <- getDistPred("CAWA")
save(dp_cawa, file=file.path(ROOT2, "dp-cawa.Rdata"))


png(file.path(ROOT, "out", "figs", "CAWA-d-2015.png"), width = 2000, height = 1000)
op <- par(mfrow=c(1,1), mar=c(1,1,1,1)+0.1)

col <- rev(brewer.pal(9, "Reds"))
z <- cut(dp_cawa, c(-1, 0, 5, 10, 50, 100, 200, 500, 1000, Inf))
plot(XYeosd, pch=".", col=col[z],
    ann=FALSE, axes=FALSE)
points(xy1, pch=19, cex=1.2)

par(op)
dev.off()


spp <- "CAWA"
Stage <- 7
BASE_YEAR <- 2015
est <- list()
map <- list()
for (wid in c(0,2,3)) {
    fl <- paste0(paste(spp, wid, Stage, BASE_YEAR, regs, sep="-"), ".Rdata")
    load(file.path(ROOT2, "species", spp, fl[1]))
    plam <- lam
    tlam <- attr(lam, "total")
    for (fn in fl[-1]) {
        cat("loading", fn, "\n");flush.console()
        load(file.path(ROOT2, "species", spp, fn))
        plam <- rbind(plam, lam)
        tlam <- rbind(tlam, attr(lam, "total"))
    }
    est[[as.character(wid)]] <- tlam
    map[[as.character(wid)]] <- plam
}

ps <- sapply(est, function(z) {
    tmp <- colSums(z)/10^6
    c(Mean=mean(tmp), quantile(tmp, c(0.025, 0.975)))
    })
colnames(ps) <- c("NALC","EOSD","LCC")
ps

png(file.path(ROOT, "out", "figs", "CAWA-all-7-2015.png"), width = 2000, height = 3000)
op <- par(mfrow=c(3,1), mar=c(1,1,1,1)+0.1)

for (i in 1:3) {
    x <- map[[i]][,"Mean"]
    probs <- c(0, 0.05, 0.1, 0.25, 0.5, 1)
    TEXT <- paste0(100*probs[-length(probs)], "-", 100*probs[-1], "%")
    Col <- rev(brewer.pal(5, "RdYlBu"))
    br <- Lc_quantile(x, probs=probs, type="L")
    zval <- if (length(unique(round(br,10))) < 5)
        rep(1, length(x)) else as.integer(cut(x, breaks=br))
    plot(XYeosd[rownames(map[[i]]),], col = Col[zval], pch=".",
        ann=FALSE, axes=FALSE)
    points(xy1, pch=19, cex=1.2)
}

par(op)
dev.off()


library(RColorBrewer)
ROOT <- "c:/bam/May2015"
load("e:/peter/bam/pred-2015/pg-clim.Rdata")
load("e:/peter/bam/pred-2015/pg-loss.Rdata")
clim$YearFire <- loss$YearFire[match(clim$pointid, loss$pointid)]
clim$YearLoss <- loss$YearLoss[match(clim$pointid, loss$pointid)]

for (fn in c("CMIJJA", "CMI", "TD", "DD0", 
    "DD5", "EMT", "MSP", "CTI", "SLP")) {

    png(file.path(ROOT, "out", "figs", paste0("x-", fn,".png")), width = 2000, height = 1000)
    op <- par(mfrow=c(1,1), mar=c(1,1,1,1)+0.1)

    Col <- brewer.pal(5, "OrRd")
    z <- cut(clim[,fn], breaks=quantile(clim[,fn], seq(0,1,0.2), na.rm=TRUE))
    plot(clim[,c("POINT_X","POINT_Y")], col = Col[z], pch=".",
        ann=FALSE, axes=FALSE)
    title(main=fn)
    legend("bottomleft", bty = "n", legend=rev(levels(z)), fill=rev(Col))
    

    par(op)
    dev.off()

}


## mapping, fid = 4

library(RColorBrewer)
library(mefa4)
library(pbapply)
ROOT <- "c:/bam/May2015"
ROOT2 <- "e:/peter/bam/pred-2015"
source("~/repos/bamanalytics/R/makingsense_functions.R")
source("~/repos/bamanalytics/R/analysis_mods.R")
load(file.path(ROOT, "out", "analysis_package_YYSS.Rdata"))
load(file.path(ROOT2, "XYfull.Rdata"))

spp <- "CAWA"
wid <- 1
Stage <- 6
BASE_YEAR <- 2015
regs <- gsub(".Rdata", "",
    gsub("pgdat-full-", "", list.files(file.path(ROOT2, "chunks2"))))

xy1 <- XYSS[YYSS[,spp] > 0, c("Xcl","Ycl")]

fl <- paste0(paste(spp, wid, Stage, BASE_YEAR, regs, sep="-"), ".Rdata")
load(file.path(ROOT2, "species", paste0(spp, "-4"), fl[1]))
plam <- lam
tlam <- attr(lam, "total")
for (fn in fl[-1]) {
    cat("loading", fn, "\n");flush.console()
    load(file.path(ROOT2, "species", paste0(spp, "-4"), fn))
    plam <- rbind(plam, lam)
    tlam <- rbind(tlam, attr(lam, "total"))
}
dim(plam)
sum(duplicated(rownames(plam)))


hist(colSums(tlam)/10^6, col=3)
sum(tlam[,1])/10^6
median(colSums(tlam)/10^6)
mean(colSums(tlam)/10^6)

z <- ifelse(rownames(XYfull) %in% names(Brandt), 2, 1)
plot(XYfull, col = z, pch=".", ann=FALSE, axes=FALSE)

z <- plam[,"Median"]
z[z >= 100] <- max(z[z < 100])
probs <- c(0, 0.05, 0.1, 0.25, 0.5, 1)
TEXT <- paste0(100*probs[-length(probs)], "-", 100*probs[-1], "%")
Col <- rev(brewer.pal(5, "RdYlBu"))
br <- Lc_quantile(z, probs=probs, type="L")

png(file.path(ROOT, "out", "figs", "CAWAfid4-2015.png"), width = 2000, height = 2000)
op <- par(mfrow=c(2,1), mar=c(1,1,1,1)+0.1)

zval <- if (length(unique(round(br,10))) < 5)
    rep(1, length(z)) else as.integer(cut(z, breaks=br))
plot(XYfull[rownames(plam),], col = Col[zval], pch=".",
    ann=FALSE, axes=FALSE)
points(xy1, pch=19, cex=1.2)


br2 <- c(0, 0.2, 0.4, 0.6, 0.8, 1, 1.2, 1.4, 1.6, 1.8, Inf)
Col2 <- rev(brewer.pal(10, "RdYlGn"))
CoV <- plam[,"SD"] / plam[,"Mean"]
zval <- cut(CoV, breaks=br2)
plot(XYfull[rownames(plam),], col = Col2[zval], pch=".",
    ann=FALSE, axes=FALSE)
points(xy1, pch=19, cex=1.2)

par(op)
dev.off()

## marginal plots

ROOT <- "e:/peter/bam/pred-2015"
library(mefa4)

load(file.path(ROOT, "pg-main.Rdata"))
x <- x[x$EOSD_COVER == 1,]
rownames(x) <- x$pointid

x <- x[rownames(plam),]
load(file.path(ROOT, "pg-loss.Rdata"))
ii <- loss$YearFire >= 9000 & !is.na(loss$YearFire)
loss$YearFire[ii] <- loss$YearFire[ii] - 8000
x$YearFire <- loss$YearFire[match(x$pointid, loss$pointid)]
x$YearLoss <- loss$YearLoss[match(x$pointid, loss$pointid)]

i <- sample.int(nrow(x), 5000)
tc <- c(rgb(1,0,0,alpha=0.2), rgb(0,0,1,alpha=0.2), rgb(0,1,0,alpha=0.2), rgb(0,0,0,alpha=0.2))
j <- as.integer(x$HAB_NALC2[i])
j[] <- 4
j[x$HAB_NALC2[i] == "Decid"] <- 1
j[x$HAB_NALC2[i] == "Mixed"] <- 2
j[x$HAB_NALC2[i] == "Conif"] <- 3

boxplot(plam[i,"Mean"] ~ x$HAB_NALC2[i], col="gold", range=0, main="Habitat", ylab="D")
boxplot(plam[i,"Mean"] ~ x$TR3[i], col="gold", range=0, main="Tree", ylab="D")
plot(plam[i,"Mean"] ~ jitter(x$HGT[i]), pch=19, cex=1, col=tc[j], main="Height", ylab="D")
legend("topleft", pch=19, col=tc, legend=c("Dec","Mix","Con","Else"))

par(mfrow=c(2,1))
plot(plam[i,"Mean"] ~ jitter(x$LIN[i]), pch=19, cex=1, col=tc[j], ylab="D")
plot(plam[i,"Mean"] ~ jitter(x$POL[i]), pch=19, cex=1, col=tc[j], ylab="D")


load(file.path(ROOT, "pg-clim.Rdata"))
rownames(clim) <- clim$pointid
clim <- clim[match(x$pointid, clim$pointid),4:14]
clim <- clim[rownames(plam),]

par(mfrow=c(2,1))
plot(plam[i,"Mean"] ~ jitter(clim$CTI[i]), pch=19, cex=1, col=tc[j], ylab="D")
plot(plam[i,"Mean"] ~ jitter(clim$SLP[i]), pch=19, cex=1, col=tc[j], ylab="D")

par(mfrow=c(2,1))
plot(plam[i,"Mean"] ~ jitter(2015-x$YearFire[i]), pch=19, cex=1, col=tc[j], ylab="D")
plot(plam[i,"Mean"] ~ jitter(2015-x$YearLoss[i]), pch=19, cex=1, col=tc[j], ylab="D")