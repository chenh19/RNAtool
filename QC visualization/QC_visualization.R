# Set the folder containing current R script as working directory
setwd(here::here())
print(paste("Current working dir:", getwd()))

# Load R packages
lapply(c("tidyverse", "filesstrings", "foreach", "doParallel"),
       require, character.only = TRUE)

# Set cpu cores for parallel computing
numCores <- detectCores(all.tests = FALSE, logical = TRUE)
print(paste("Parallel computing:", numCores, "cores will be used for data processing"))

# Detect files
files <- list.files(pattern='*.allCells.csv')

################################################################################

# A.PDF plots of UMIs
if (dir.exists("./A_UMI_PDF_plots/")==FALSE){
  dir.create("./A_UMI_PDF_plots/")
}
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  csv <- read.csv(file)
  csv <- dplyr::filter(csv, umis >= 300 & umis <= 10000)
  barcode_dist <- csv[,"umis"]
  filename <- paste0("./A_UMI_PDF_plots/", file, ".UMI-PDF.tiff")
  filename <- gsub("\\.csv", "", filename)
  title <- paste0("UMI PDF: ", file)
  title <- gsub("\\.csv", "", title)
  title <- gsub("\\.Rat.allCells", " (Rat, all cells)", title)
  title <- gsub("\\: soc-", ": Socialized-", title)
  title <- gsub("\\: iso-", ": Isolated-", title)
  tiff(file=filename, width=8, height=5, units="in", res=600, compress="lzw")
  PDF <- hist(barcode_dist, 
              freq=F, 
              breaks=100, 
              xlim = c(0,10000),
              ylim = c(0,5.2e-4), 
              main= title, 
              xlab="UMI counts in each barcode (cell)", 
              ylab="Probability Density Function (PDF)")
  segments(x0 = 1000,
           x1 = 1000,
           y0 = 0,
           y1 = 3.5e-4,
           lwd = 2,
           lty=2,
           col = "red") 
  text(900, 4e-4, "Unique UMI count = 1000", col="red", adj=0)
  dev.off()
}

################################################################################

# B.PDF plots of genes
if (dir.exists("./B_Gene_PDF_plots/")==FALSE){
  dir.create("./B_Gene_PDF_plots/")
}
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  csv <- read.csv(file)
  csv <- dplyr::filter(csv, genes >= 75 & genes <= 4000)
  gene_dist <- csv[,"genes"]
  filename <- paste0("./B_Gene_PDF_plots/", file, ".Gene-PDF.tiff")
  filename <- gsub("\\.csv", "", filename)
  title <- paste0("Gene PDF: ", file)
  title <- gsub("\\.csv", "", title)
  title <- gsub("\\.Rat.allCells", " (Rat, all cells)", title)
  title <- gsub("\\: soc-", ": Socialized-", title)
  title <- gsub("\\: iso-", ": Isolated-", title)
  tiff(file=filename, width=8, height=5, units="in", res=600, compress="lzw")
  PDF <- hist(gene_dist, 
              freq=F, 
              breaks=100, 
              xlim = c(0,4000),
              ylim = c(0,5.2e-4), 
              main= title, 
              xlab="Gene counts in each barcode (cell)", 
              ylab="Probability Density Function (PDF)")
  segments(x0 = 600,
           x1 = 600,
           y0 = 0,
           y1 = 3.5e-4,
           lwd = 2,
           lty=2,
           col = "red") 
  text(550, 4e-4, "Unique Gene count = 600", col="red", adj=0)
  dev.off()
}

################################################################################

# C.Barcode rank plot
if (dir.exists("./C_Barcode_Rank_plots/")==FALSE){
  dir.create("./C_Barcode_Rank_plots/")
}
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  csv <- read.csv(file)
  csv <- csv %>%
    arrange(desc(umis)) %>%
    mutate(rank = row_number())
  percentile_99 <- quantile(csv$umis, 0.99)
  percentile_99_10 <- quantile(csv$umis, 0.99)/10
  csv$segment <- ifelse(csv$umis >= percentile_99_10, "High quality", "Low quality")
  filename <- paste0("./C_Barcode_Rank_plots/", file, ".BR.tiff")
  filename <- gsub("\\.csv", "", filename)
  title <- paste0("Barcode Rank: ", file)
  title <- gsub("\\.csv", "", title)
  title <- gsub("\\.Rat.allCells", " (Rat, all cells)", title)
  title <- gsub("\\: soc-", ": Socialized-", title)
  title <- gsub("\\: iso-", ": Isolated-", title)
  p <- ggplot2::ggplot(csv, aes(x = rank, y = umis, color = segment)) +
    geom_line(size = 2) +
    scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
    scale_y_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
    labs(x = "Barcode Rank", y = "UMI counts") +
    theme_bw () + 
    ggtitle(title) +
    scale_color_manual(values = c("High quality" = "blue", "Low quality" = "darkgray")) +
    geom_hline(yintercept = percentile_99, color = "blue", linetype = "dashed", size=0.8) +
    geom_hline(yintercept = percentile_99_10, color = "red", linetype = "dashed", size=0.8) +
    annotate("text", x = 2, y = percentile_99, label = "99th Percentile", color = "blue", hjust = 0, vjust = -0.5) +
    annotate("text", x = 2, y = percentile_99_10, label = "99th Percentile/10", color = "red", hjust = 0, vjust = -0.5) +
    theme(
      legend.position = "none",
      plot.title = element_text(hjust = 0.5, face = "bold")  # Centers the title
    )
  ggsave(filename, plot = p, width = 6, height = 5, dpi = 600, compression = "lzw")
}

################################################################################

# D.Gene counts vs UMI counts
if (dir.exists("./D_Gene_vs_UMI_plots/")==FALSE){
  dir.create("./D_Gene_vs_UMI_plots/")
}
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  csv <- read.csv(file)
  filename <- paste0("./D_Gene_vs_UMI_plots/", file, ".Gene_UMI.tiff")
  filename <- gsub("\\.csv", "", filename)
  title <- paste0("Gene vs UMI: ", file)
  title <- gsub("\\.csv", "", title)
  title <- gsub("\\.Rat.allCells", " (Rat, all cells)", title)
  title <- gsub("\\: soc-", ": Socialized-", title)
  title <- gsub("\\: iso-", ": Isolated-", title)
  max_umi <- max(csv$umis)
  max_gene <- max(csv$genes)
  p <- ggplot(csv, aes(x = umis, y = genes)) +
    geom_point(size = 0.5, color = "blue") +  # Adjust size and color as needed
    labs(x = "UMI count", y = "Gene count") +
    theme_bw () + 
    ggtitle(title) +
    geom_vline(xintercept = 1000, color = "red", linetype = "dashed", size=0.5) +
    geom_hline(yintercept = 600, color = "red", linetype = "dashed", size=0.5) +
    
    annotate("text", x = 1000, y = max_gene, label = "Unique UMI count = 1000", color = "red", hjust = -0.05, vjust = 0) +
    annotate("text", x = max_umi, y = 600, label = "Unique Gene count = 600", color = "red", hjust = 0.8, vjust = -0.9) +
    theme(
      legend.position = "none",
      plot.title = element_text(hjust = 0.5, face = "bold")  # Centers the title
    )
  p <- p + scale_x_continuous(limits = c(0, (max_umi+2000)))
  p <- p + scale_y_continuous(limits = c(0, (max_gene+200)))
  ggsave(filename, plot = p, width = 6, height = 5, dpi = 600, compression = "lzw")
}

################################################################################

# Cleanup
rm(list = ls())
