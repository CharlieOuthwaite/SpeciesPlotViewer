#install.packages( "maps", dependencies = TRUE) #run this to install R package maps
################################- warning this will update existing packages if already installed

#*save the following code in a file named app.R *
library(shiny)
library(rsconnect)
library(DT)

##Section 1 ____________________________________________________
#load your data or create a data table:

# good species in the paper list.  This takes the Species_Trends.csv file 
# that is found in the repo so only "good" species are able to be selected in this app.
good_sp <- read.csv("data/Species_Trends.csv")

# where are the occupancy plots
plot_dir <- ("images")

# what are the group names?
# required for the drop down selection.
group_names <- as.character(unique(good_sp$Group))


##Section 2 ____________________________________________________
#set up the user interface
ui = shinyUI(
  
  
  fluidPage( #allows layout to fill browser =
    titlePanel("Species Occupancy Plot Viewer"),
    #adds a title to page and browser tab

    # to the left will be two drop down selection boxes, 
    # one for group, one for species in that group.
    sidebarPanel( #designates location of following items
      htmlOutput("group_selector"),# add selectinput boxs
      htmlOutput("species_selector")# from objects created in server
    ),
    
    # to the right of the side panel will be the info, plots and data table
    mainPanel(
      
      # General text intro
      p("This app presents outputs that are avaialble from the following NERC EIDC repository:
        https://catalogue.ceh.ac.uk/documents/0ec7e549-57d4-4e2d-b2d3-2199e1578d84"),
      
      # title for next section
      h3("Annual species occupancy and detection estimates"),
      
      # description of what is included
      p("Two plots are presented here.  The first shows a plot of average UK occupancy for the selected species.  The
        points represent the average occupancy for each year.  The grey shaded area represents
        the uncertainty around the estimate in the form of the 95% credible interval. The second shows a plot of the
        detection probabilities over time.  The rhat value represents whether the estimate has converged or not.  
        Grey points along the top of the plot represent those year with data contributing to the estimate in that year, 
        years without data are estimated as a combination of a prior and data in the surrounding years.  Please see
        the relevant papers for details on methods."),
      
      # present the occupancy plot
      imageOutput("sp_plot"), #put plot item in main area
      
      # present the detection plot
      #imageOutput("det_plot"),
      
      # Title for trend section
      h3("Data information and species trend"),

      # present the table of info 
      DT::dataTableOutput("table"),
      
      # description of info in the table
      p("The table presents some information associated with the selected species. This includes
        the group and species name, the number of years of data meeting the modelling criteria, 
        the first and last year of data, the total number of records of this species used in 
        the model run, the mean growth rate (calculated as the annual percentage growth rate)
        including the upper and lower credible intervals of this estimates and the associated
        precision."),
      
      # title 
      h3("References"),
      
      # add in the relevant citations here
      p("If you use the data presented in this app or in the associated papers, please use
        the following citations:
        
        add in paper refs here when available"
        
        ),
      
      p("The dataset itself can be cited as follows:
        Outhwaite, C.L.; Powney, G.D.; August, T.A.; Chandler, R.E.; Rorke, S.; Pescott, O.; 
        Harvey, M.; Roy, H.E.; Fox, R.; Walker, K.; Roy, D.B.; Alexander, K.; Ball, S.; Bantock, T.; 
        Barber, T.; Beckmann, B.C.; Cook, T.; Flanagan, J.; Fowles, A.; Hammond, P.; Harvey, P.; Hepper, 
        D.; Hubble, D.; Kramer, J.; Lee, P.; MacAdam, C.; Morris, R.; Norris, A.; Palmer, S.; Plant, C.; 
        Simkin, J.; Stubbs, A.; Sutton, P.; Telfer, M.; Wallace, I.; Isaac, N.J.B. (2019). 
        Annual estimates of occupancy for bryophytes, lichens and invertebrates in the UK (1970-2015). 
        NERC Environmental Information Data Centre. 
        https://doi.org/10.5285/0ec7e549-57d4-4e2d-b2d3-2199e1578d84
        ")
      
      
      )
    ) )


##Section 3 ____________________________________________________
#server controls what is displayed by the user interface
server = shinyServer(function(input, output) {
  #creates logic behind ui outputs ** pay attention to letter case in names
  
  
  # create the group level selector drop down
  output$group_selector = renderUI({ #creates State select box object called in ui
    selectInput(inputId = "group", #name of input
                label = "Group", #label displayed in ui
                choices = group_names,
                # calls unique values from the State column in the previously created table
                selected = "Ants") #default choice (not required)
  })
  
  # create the species level selector drop down
  output$species_selector = renderUI({#creates species select box object called in ui
    
        # just select those for the selected group
    sp_list <- good_sp[good_sp$Group == input$group, ]
    
    # what are the species names in this group for in the drop down menu?
    species_names <- as.character(sp_list$Species)
    
    selectInput(inputId = "species_name", #name of input
                label = "Species:", #label displayed in ui
                choices = species_names, #calls list of available counties
                selected = species_names[1], size = 1300, selectize = F)
  })
  
  
  # create the occupancy plot section of the main panel
  output$sp_plot = renderImage({ #creates a the plot to go in the mainPanel
    
    # get the correct subfolder in the images dir
    output_dir <- paste(plot_dir, "/", input$group, sep = "")

    # List the plot files in the directory of the selected group
    files <- list.files(output_dir)
    
    # add on the name of the selected species
    plot_file <- paste0(output_dir, "/", good_sp[good_sp$Species == input$species_name, 'Species'], ".png")
    
    # return the plot
    return(list(
      src = plot_file,
      filetype = "png",
      alt = "Species plot",
      width = 400, 
      height = 400
    ))
    
    
    
  }, delete = FALSE)
  
  
  ### TOM/MARK:  I think you just need to include the plot files into a subdirectory of                ###
  ### the "images" folder in the app, and complete the section below to add in the detection plots :)  ###
  
  # create the detection plot section of the main panel
  #output$det_plot = renderImage({ #creates a the plot to go in the mainPanel
    
    # get the correct subfolder in the images dir
    #det_dir <- paste(plot_dir, "/", input$group, sep = "")
    
    # List the plot files in the directory of the selected group
    #files <- list.files(det_dir)
    
    # add on the name of the selected species
    #det_plot_file <- paste0(det_dir, "/", good_sp[good_sp$Species == input$species_name, 'Species'], ".png")
    
    # return the plot
    #return(list(
    #  src = det_plot_file,
    #  filetype = "png",
    #  alt = "Species plot",
    #  width = 400, 
    #  height = 400
    #))
    
  #}, delete = FALSE)
  
  
  
  # creating the data table by using selected species
  output$table <- DT::renderDataTable(DT::datatable({
    
    # where is the trend data
    data <- good_sp
    
    # select the row for the selected species
    data <- data[data$Species == input$species_name, ] 
    
    # round up the values to 3 dp.
    data[, 7:10] <- round(data[, 7:10], 3)

    data
  }))
  
  
})#close the shinyServer

##Section 4____________________________________________________
shinyApp(ui = ui, server = server) #need this if combining ui and server into one file.