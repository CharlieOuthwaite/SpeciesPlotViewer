plot_dir <- ("images")


for(group in good_sp$Group){
  
  for(species in good_sp[good_sp$Group == group, "Species"])
 
    plots <- list.files(paste0(plot_dir, "/", group))
    
     
}





#  rename the files
# Funtion from Nick to change species names to lower case except first letter

sentenceCase <- function(x) {
  paste(toupper(substring(x, 1, 1)), tolower(substring(x, 2)),
        sep = "", collapse = " ")
}

files <- list.files(plot_dir)

for(file in files){
  
  plots <- list.files(paste0(plot_dir, "/", file))
  
 for(plot in plots){
   file.rename(paste0(plot_dir, "/", file, "/", plot), paste0(plot_dir, "/", file, "/", sentenceCase(sub("_yearly_occ", "", plot))))
 }  
}


