# Set the folder containing current R script as working directory
setwd(here::here())
print(paste("Current working dir:", getwd()))

# Load R packages
lapply(c("tidyverse", "filesstrings", "foreach", "doParallel", "writexl"),
       require, character.only = TRUE)

# Set cpu cores for parallel computing
numCores <- detectCores(all.tests = FALSE, logical = TRUE)
print(paste("Parallel computing:", numCores, "cores will be used for data processing"))

# Create folders
## original files
if (dir.exists("./original_files/")==FALSE){
  dir.create("./original_files/")
}
if (dir.exists("./original_files/A_allCells_CSV/")==FALSE){
  dir.create("./original_files/A_allCells_CSV/")
}
## output
if (dir.exists("./output/")==FALSE){
  dir.create("./output/")
}
if (dir.exists("./output/A_UMI_PDF_plots/")==FALSE){
  dir.create("./output/A_UMI_PDF_plots/")
}
if (dir.exists("./output/B_Gene_PDF_plots/")==FALSE){
  dir.create("./output/B_Gene_PDF_plots/")
}
if (dir.exists("./output/C_Barcode_Rank_plots/")==FALSE){
  dir.create("./output/C_Barcode_Rank_plots/")
}
if (dir.exists("./output/D_Gene_vs_UMI_plots/")==FALSE){
  dir.create("./output/D_Gene_vs_UMI_plots/")
}
if (dir.exists("./output/E_Summary_table/")==FALSE){
  dir.create("./output/E_Summary_table/")
}

# Detect files
files <- list.files(pattern='*.allCells.csv')

################################################################################

# UMI cutoff table
summary_table <- list()
for (file in files) {
  #file <- "iso-F-04.Rat.allCells.csv"
  csv <- read.csv(file)
  #any(is.na(csv$genes))
  #any(is.na(csv$umis))
  
  sample <- paste0(file)
  sample <- gsub("\\.Rat.allCells.csv", " (Rat)", sample)
  sample <- gsub("\\soc-", "Socialized-", sample)
  sample <- gsub("\\iso-", "Isolated-", sample)
  
  before_qc <- c(nrow(csv), # barcode counts
                 round(mean(csv$umis)), # mean of umi counts
                 median(csv$umis), # median of umi counts
                 max(csv$umis), # max of umi counts
                 min(csv$umis), # min of umi counts
                 round(mean(csv$genes)), # mean of umi counts
                 median(csv$genes), # median of umi counts
                 max(csv$genes), # max of umi counts
                 min(csv$genes) # min of umi counts
                 )
  
  percentile_99_10 <- quantile(csv$umis, 0.99)/10
  csv <- dplyr::filter(csv, umis >= percentile_99_10)
  percentile_99_10_gene <- min(csv$genes)
  
  after_qc <- c(nrow(csv), # barcode counts
                round(mean(csv$umis)), # mean of umi counts
                median(csv$umis), # median of umi counts
                max(csv$umis), # max of umi counts
                min(csv$umis), # min of umi counts
                round(mean(csv$genes)), # mean of umi counts
                median(csv$genes), # median of umi counts
                max(csv$genes), # max of umi counts
                min(csv$genes) # min of umi counts
                )
  
  summary <- c(sample, before_qc, round(percentile_99_10), round(percentile_99_10_gene), after_qc)
  
  summary_table[[file]] <- summary
}
summary_table <- as.data.frame(do.call(rbind, summary_table))
rownames(summary_table) <- NULL
colnames(summary_table) <- c("Sample", "Cell_count(before_QC)", 
                             "Mean_UMI_count(before_QC)", "Median_UMI_count(before_QC)", "Max_UMI_count(before_QC)", "Min_UMI_count(before_QC)",
                             "Mean_Gene_count(before_QC)", "Median_Gene_count(before_QC)", "Max_Gene_count(before_QC)", "Min_Gene_count(before_QC)",
                             "UMI_count_cutoff", "Gene_count_cutoff", "Cell_count(after_QC)", 
                             "Mean_UMI_count(after_QC)", "Median_UMI_count(after_QC)", "Max_UMI_count(after_QC)", "Min_UMI_count(after_QC)",
                             "Mean_Gene_count(after_QC)", "Median_Gene_count(after_QC)", "Max_Gene_count(after_QC)", "Min_Gene_count(after_QC)")

# Export spreadsheet
file <- "summary_table.xlsx"
sheets <- list("Summary table" = summary_table)
write_xlsx(sheets, file)
file.move(file, "./output/E_Summary_table/", overwrite=TRUE)
rm("file", "sheets", "sample", "summary", "percentile_99_10", "percentile_99_10_gene", "before_qc", "after_qc", "csv", "summary_table")


################################################################################

# A.PDF plots of UMIs
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  #file <- "iso-F-04.Rat.allCells.csv"
  csv <- read.csv(file)
  percentile_99 <- quantile(csv$umis, 0.99)
  percentile_99_10 <- quantile(csv$umis, 0.99)/10
  csv <- dplyr::filter(csv, umis >= 100 & umis <= 10000)
  barcode_dist <- csv[,"umis"]
  filename <- paste0("./output/A_UMI_PDF_plots/", file, ".UMI.tiff")
  filename <- gsub("\\.csv", "", filename)
  title <- paste0("UMI Count Frequency: ", file)
  title <- gsub("\\.csv", "", title)
  title <- gsub("\\.Rat.allCells", " (Rat, all cells)", title)
  title <- gsub("\\: soc-", ": Socialized-", title)
  title <- gsub("\\: iso-", ": Isolated-", title)
  tiff(file=filename, width=8, height=5, units="in", res=600, compress="lzw")
  PDF <- hist(barcode_dist, 
              freq=F, 
              breaks=100, 
              xlim = c(0,10000),
              ylim = c(0,2.2e-4), 
              main= title, 
              xlab="UMI Count in each Barcode (cell)", 
              ylab="Frequency",
              yaxt = "n")
  y_ticks <- axTicks(2)
  y_labels <- formatC(y_ticks, format = "e", digits = 1)
  axis(2, at = y_ticks, labels = y_labels)
  
  # 99th percentile/10 line
  segments(x0 = percentile_99_10,
           x1 = percentile_99_10,
           y0 = 0,
           y1 = 2.2e-4,
           lwd = 2,
           lty=2,
           col = "red") 
  text(paste0(round(percentile_99_10)+1000), 1.9e-4, paste0("UMI >= ", round(percentile_99_10), " (99th Percentile/10)"), col="red", adj=0)
  
  # 99th percentile line
  segments(x0 = percentile_99,
           x1 = percentile_99,
           y0 = 0,
           y1 = 1.5e-4,
           lwd = 2,
           lty=2,
           col = "blue") 
  text(paste0(round(percentile_99)+750), 1.2e-4, paste0("UMI = ", round(percentile_99), " (99th Percentile)"), col="blue", adj=0)

  dev.off()
}

################################################################################

# B.PDF plots of genes
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  #file <- "iso-F-04.Rat.allCells.csv"
  csv <- read.csv(file)
  percentile_99 <- quantile(csv$umis, 0.99)
  percentile_99_10 <- quantile(csv$umis, 0.99)/10
  csv2 <- dplyr::filter(csv, umis >= percentile_99)
  percentile_99_gene <- min(csv2$genes)
  csv3 <- dplyr::filter(csv, umis >= percentile_99_10)
  percentile_99_10_gene <- min(csv3$genes)
  csv <- dplyr::filter(csv, genes >= 75 & genes <= 4000)
  gene_dist <- csv[,"genes"]
  filename <- paste0("./output/B_Gene_PDF_plots/", file, ".Gene.tiff")
  filename <- gsub("\\.csv", "", filename)
  title <- paste0("Gene Count Frequency: ", file)
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
              xlab="Gene Count in each Barcode (cell)", 
              ylab="Frequency",
              yaxt = "n")
  y_ticks <- axTicks(2)
  y_labels <- formatC(y_ticks, format = "e", digits = 1)
  axis(2, at = y_ticks, labels = y_labels)
  
  # 99th percentile/10 line
  segments(x0 = percentile_99_10_gene,
           x1 = percentile_99_10_gene,
           y0 = 0,
           y1 = 5e-4,
           lwd = 2,
           lty=2,
           col = "red") 
  text(paste0(percentile_99_10_gene+300), 4.3e-4, paste0("Gene >= ", percentile_99_10_gene, " (when UMI >= 99th Percentile/10)"), col="red", adj=0)
  
  # 99th percentile line
  segments(x0 = percentile_99_gene,
           x1 = percentile_99_gene,
           y0 = 0,
           y1 = 3.5e-4,
           lwd = 2,
           lty=2,
           col = "blue") 
  text(paste0(percentile_99_gene+200), 2.8e-4, paste0("Gene = ", percentile_99_gene, " (when UMI = 99th Percentile)"), col="blue", adj=0)

  dev.off()
}

################################################################################

# C.Barcode rank plot
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  #file <- "iso-F-04.Rat.allCells.csv"
  csv <- read.csv(file)
  percentile_99 <- quantile(csv$umis, 0.99)
  percentile_99_10 <- quantile(csv$umis, 0.99)/10
  csv <- csv %>%
    arrange(desc(umis)) %>%
    mutate(rank = row_number())
  csv$segment <- ifelse(csv$umis >= percentile_99_10, "High quality", "Low quality")
  filename <- paste0("./output/C_Barcode_Rank_plots/", file, ".BR.tiff")
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
    labs(x = "Barcode (cell) Rank", y = "Unique UMI counts") +
    theme_bw () + 
    ggtitle(title) +
    scale_color_manual(values = c("High quality" = "blue", "Low quality" = "darkgray")) +
    
    # 99th percentile/10 line
    geom_hline(yintercept = percentile_99_10, color = "red", linetype = "dashed", size=0.8) +
    annotate("text", x = 2, y = percentile_99_10, label = paste0("UMI >= ", round(percentile_99_10), " (99th Percentile/10)"), color = "red", hjust = 0.1, vjust = -0.5) +
    
    # 99th percentile line
    geom_hline(yintercept = percentile_99, color = "blue", linetype = "dashed", size=0.8) +
    annotate("text", x = 2, y = percentile_99, label = paste0("UMI = ", round(percentile_99), " (99th Percentile)"), color = "blue", hjust = 0.1, vjust = -0.5) +
    
    theme(
      legend.position = "none",
      plot.title = element_text(hjust = 0.5, face = "bold")  # Centers the title
    )
  ggsave(filename, plot = p, width = 6, height = 5, dpi = 600, compression = "lzw")
}

################################################################################

# D.Gene counts vs UMI counts
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  #file <- "iso-F-04.Rat.allCells.csv"
  csv <- read.csv(file)
  percentile_99 <- quantile(csv$umis, 0.99)
  percentile_99_10 <- quantile(csv$umis, 0.99)/10
  csv2 <- dplyr::filter(csv, umis >= percentile_99)
  percentile_99_gene <- min(csv2$genes)
  csv3 <- dplyr::filter(csv, umis >= percentile_99_10)
  percentile_99_10_gene <- min(csv3$genes)
  filename <- paste0("./output/D_Gene_vs_UMI_plots/", file, ".Gene_UMI.tiff")
  filename <- gsub("\\.csv", "", filename)
  title <- paste0("Gene vs UMI: ", file)
  title <- gsub("\\.csv", "", title)
  title <- gsub("\\.Rat.allCells", " (Rat, all cells)", title)
  title <- gsub("\\: soc-", ": Socialized-", title)
  title <- gsub("\\: iso-", ": Isolated-", title)
  max_umi <- max(csv$umis)
  max_gene <- max(csv$genes)
  p <- ggplot(csv, aes(x = umis, y = genes)) +
    geom_point(size = 0.8, color = "darkslateblue") +  # Adjust size and color as needed
    labs(x = "UMI Count", y = "Gene Count") +
    theme_bw () + 
    ggtitle(title) +
    
    ## vertical lines
    ### 99th percentile/10 line
    geom_vline(xintercept = percentile_99_10, 
               color = "red", linetype = "dashed", size=0.5) +
    annotate("text", x = percentile_99_10, y = max_gene, 
             label = paste0("UMI >=", round(percentile_99_10), " (99th Percentile/10)"), 
             color = "red", hjust = -0.05, vjust = -3.5) +
    ### 99th percentile line
    geom_segment(aes(x = percentile_99, xend = percentile_99, y = 0, yend = max_gene+300), 
                 color = "blue", linetype = "dashed", size = 0.5) +
    annotate("text", x = percentile_99, y = max_gene, 
             label = paste0("UMI =", round(percentile_99), " (99th Percentile)"), 
             color = "blue", hjust = -0.05, vjust = 1) +
    
    ## horizontal lines
    ### 99th percentile/10 line
    geom_hline(yintercept = percentile_99_10_gene, 
               color = "red", linetype = "dashed", size=0.5) +
    annotate("text", x = max_umi, y = percentile_99_10_gene, 
             label = paste0("Gene >= ", round(percentile_99_10_gene), " (when UMI >= 99th Percentile/10)"),
             color = "red", hjust = 0.9, vjust = -0.9) +
    ### 99th percentile line
    geom_segment(aes(x = 0, xend = max_umi+2000, y = percentile_99_gene, yend = percentile_99_gene), 
                 color = "blue", linetype = "dashed", size = 0.5) +
    annotate("text", x = max_umi, y = percentile_99_gene, 
             label = paste0("Gene =", round(percentile_99_gene), " (when UMI = 99th Percentile)"), 
             color = "blue", hjust = 0.95, vjust = -0.9) +
    
    theme(
      legend.position = "none",
      plot.title = element_text(hjust = 0.5, face = "bold")  # Centers the title
    )
  p <- p + scale_x_continuous(limits = c(0, (max_umi+2000)))
  p <- p + scale_y_continuous(limits = c(0, (max_gene+1000)))
  ggsave(filename, plot = p, width = 6, height = 5, dpi = 600, compression = "lzw")
}

################################################################################

# Cleanup
registerDoParallel(numCores)
foreach (file = files) %dopar% {
  file.move(file, "./original_files/A_allCells_CSV/", overwrite=TRUE)
}
rm(list = ls())
