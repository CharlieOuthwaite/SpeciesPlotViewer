#install.packages( "maps", dependencies = TRUE) #run this to install R package maps
################################- warning this will update existing packages if already installed

#*save the following code in a file named app.R *
library(shiny)
library(rsconnect)

##Section 1 ____________________________________________________
#load your data or create a data table as follows:

# good species in the paper list
good_sp <- read.csv("data/Species_Trends.csv")

plot_dir <- ("images")

group_names <- as.character(unique(good_sp$Group))


##Section 2 ____________________________________________________
#set up the user interface
ui = shinyUI(
  fluidPage( #allows layout to fill browser =
    titlePanel("Species Occupancy Plot Viewer"),
    #adds a title to page and browser tab
    #-use "title = 'tab name'" to name browser tab
    sidebarPanel( #designates location of following items
      htmlOutput("group_selector"),#add selectinput boxs
      htmlOutput("species_selector")# from objects created in server
    ),
    
    mainPanel(
      
      h3("Annual species occupancy estimates"),
      
      p("This figure shows a plot of average UK occupancy for the selected species.  The
        points represent the average occupancy for each year.  The grey shaded area represents
        the uncertainty around the estimate in the form of the 95% credible interval.  The 
        number of records contributing to the estimates are shown in the plot title.  The rhat value
        represents whether the estimate has converged or not.  Grey points along the top of the plot
        represent those year with data contributing to the estimate in that year, years without data
        are estimated as a combination of a prior and data in the surrounding years.  Please see
        the data paper and my paper in Ecological Indicators for details on the methods.
        
        "),
      
      
      imageOutput("sp_plot") #put plot item in main area
      )
    ) )


##Section 3 ____________________________________________________
#server controls what is displayed by the user interface
server = shinyServer(function(input, output) {
  #creates logic behind ui outputs ** pay attention to letter case in names
  
  output$group_selector = renderUI({ #creates State select box object called in ui
    selectInput(inputId = "group", #name of input
                label = "Group", #label displayed in ui
                choices = group_names,
                # calls unique values from the State column in the previously created table
                selected = "Ants") #default choice (not required)
  })
  
  
  output$species_selector = renderUI({#creates species select box object called in ui
    
    
    #just select those for this group
    sp_list <- good_sp[good_sp$Group == input$group, ]
    
    # what are the species names for in the drop down menu?
    species_names <- as.character(sp_list$Species)
    
    
    
    
    
    selectInput(inputId = "species_name", #name of input
                label = "Species:", #label displayed in ui
                choices = species_names, #calls list of available counties
                selected = species_names[1], size = 1300, selectize = F)
  })
  
  
  
  output$sp_plot = renderImage({ #creates a the plot to go in the mainPanel
    
    
    output_dir <- paste(plot_dir, "/", input$group, sep = "")
    #  output_dir <- paste(plot_dir, "/", "Ants", sep = "")
    
    
    
    # List the plot files in the directory
    files <- list.files(output_dir)
    
    
    # add on the name of the species
    plot_file <- paste0(output_dir, "/", good_sp[good_sp$Species == input$species_name, 'Species'], ".png")
    
    
    return(list(
      src = plot_file,
      filetype = "png",
      alt = "Species plot",
      width = 600, 
      height = 600
    ))
    
    
  }, delete = FALSE)
  
  
})#close the shinyServer

##Section 4____________________________________________________
shinyApp(ui = ui, server = server) #need this if combining ui and server into one file.