library(shiny)
library(shinythemes)
library(stringr)
library(jsonlite)
library(ape)
library(plotly)

# Define UI
ui <- fluidPage(
  theme = shinytheme("cosmo"),

  # Title
  titlePanel(
    h1("VAXPOX WP3 - Metadata & Sequence Submission (Country A)",
       style = "color: #1F4E79; text-align: center; margin-bottom: 30px;")
  ),

  sidebarLayout(
    # Sidebar with input controls
    sidebarPanel(
      width = 4,

      h3("Sample Information", style = "color: #1F4E79;"),

      # Load preloaded samples
      h4("Load Sample", style = "color: #1F4E79;"),
      selectInput("load_sample", "Select a preloaded sample:",
                  choices = c("", "VPCAM-99-001", "VPCAM-99-002", "VPCAM-99-003",
                             "VPCI-99-001", "VPCI-99-002", "VPCI-99-003",
                             "VPMADA-99-001", "VPMADA-99-002",
                             "VPRCA-99-001", "VPRCA-99-002")),
      actionButton("load_btn", "Load Sample", style = "background-color: #1F4E79; color: white; width: 100%; padding: 10px;"),

      hr(),

      # Demographic Data
      h4("Demographic Data"),
      textInput("sample_id", "Sample ID", placeholder = "e.g., VPCAM-99-001"),
      numericInput("birth_year", "Year of Birth", value = 1990, min = 1920, max = 2024),
      selectInput("sex", "Sex", choices = c("", "Male", "Female", "Other")),
      textInput("residence", "Place of Residence", placeholder = "e.g., Yaoundé, Cameroon"),

      hr(),

      # Clinical Data
      h4("Clinical Data"),
      dateInput("symptom_date", "Symptom Onset Date", value = Sys.Date()),
      numericInput("num_lesions", "Number of Skin Lesions", value = 10, min = 0, max = 1000),
      selectInput("vaccination_status", "Vaccination Status (smallpox/mpox)",
                  choices = c("", "Never vaccinated", "Vaccinated - unknown date", "Vaccinated")),
      dateInput("vaccination_date", "Vaccination Date (if known)", value = NA),
      selectInput("previous_mpox", "Previous mpox infection",
                  choices = c("", "No", "Yes - confirmed", "Yes - suspected")),
      selectInput("febrile_rash_history", "History of febrile rash",
                  choices = c("", "No", "Yes")),
      selectInput("underlying_conditions", "Underlying conditions (immunosuppression)",
                  choices = c("", "No", "Yes - HIV/AIDS", "Yes - Other immunosuppression", "Unknown")),

      hr(),

      # Epidemiological Data
      h4("Epidemiological Data"),
      textInput("profession", "Profession", placeholder = "e.g., Healthcare worker, Sex worker"),
      selectInput("contact_patients", "Contact with mpox patients (past 21 days)",
                  choices = c("", "No", "Yes - confirmed", "Yes - suspected")),
      selectInput("contact_animals", "Contact with animals (past 21 days)",
                  choices = c("", "No", "Yes - domestic", "Yes - wild", "Yes - both"))
    ),

    # Main panel with sample data and sequence input
    mainPanel(
      width = 8,

      tabsetPanel(
        # Tab 1: Biological Data
        tabPanel(
          "Biological Data",
          h3("Biological & Sequencing Information"),

          fluidRow(
            column(6,
              dateInput("sampling_date", "Sampling Date", value = Sys.Date()),
              selectInput("sample_type", "Sample Type",
                         choices = c("", "Pus swab", "Crust swab", "Throat swab", "Whole blood", "Other"))
            ),
            column(6,
              numericInput("ct_value", "PCR Ct Value", value = 20, min = 0, max = 45, step = 0.1),
              selectInput("pcr_result", "PCR Result",
                         choices = c("", "Positive", "Negative"))
            )
          ),

          h4("Genome Sequence Input"),
          p("Paste your complete MPXV genome sequence below (FASTA or raw sequence):"),

          textAreaInput(
            "genome_sequence",
            label = NULL,
            height = "250px",
            placeholder = "Paste genome sequence here (or >sequence_header followed by sequence)\nExample:\n>MPXV_sample_1\nATGCATGCATGCATGC..."
          ),

          fluidRow(
            column(6,
              h4("Sequence Length (bp):"),
              textOutput("seq_length_display")
            ),
            column(6,
              h4("GC Content (%):"),
              textOutput("gc_content_display")
            )
          ),

          p(em("Note: Sequence statistics will be calculated automatically"),
            style = "color: #666; margin-top: 10px;")
        ),

        # Tab 2: Summary
        tabPanel(
          "Summary",
          h3("Data Summary"),

          div(
            style = "background-color: #f5f5f5; padding: 20px; border-radius: 5px;",

            h4("Sample Overview", style = "color: #1F4E79;"),
            tableOutput("summary_table"),

            br(),

            h4("Sequence Summary", style = "color: #1F4E79;"),
            tableOutput("sequence_summary_table")
          )
        ),

        # Tab 3: Phylogenetic Tree
        tabPanel(
          "Phylogenetic Tree",
          h3("MPOX Genome Phylogeny - African Isolates"),

          p("Maximum likelihood phylogenetic tree of the 10 MPOX genome sequences from Africa.",
            style = "color: #666; margin-bottom: 20px;"),

          imageOutput("tree_plot"),

          br(),

          div(
            style = "background-color: #f5f5f5; padding: 15px; border-radius: 5px;",
            h4("Tree Information", style = "color: #1F4E79;"),
            p("This phylogenetic tree shows the evolutionary relationships among the 10 MPOX genome sequences"),
            p("aligned using MAFFT and inferred using maximum likelihood phylogenetic analysis.")
          )
        ),

        # Tab 4: Export
        tabPanel(
          "Export",
          h3("Export Data"),

          p("Export your submission in standard formats:"),

          fluidRow(
            column(6,
              downloadButton("download_csv", "Download as CSV",
                            style = "background-color: #1F4E79; color: white; width: 100%; padding: 10px;")
            ),
            column(6,
              downloadButton("download_fasta", "Download Sequence (FASTA)",
                            style = "background-color: #1F4E79; color: white; width: 100%; padding: 10px;")
            )
          ),

          br(), br(),

          h4("JSON Format"),
          p("Copy the JSON representation of your submission:"),

          verbatimTextOutput("json_output")
        )
      )
    )
  ),

  # Footer
  fluidRow(
    column(12,
      hr(),
      p("VAXPOX WP3 Metadata Submission Tool | Last updated: 2026",
        style = "color: #999; font-size: 12px; text-align: center;")
    )
  )
)

# Define server
server <- function(input, output, session) {

  # Load toy metadata
  toy_data <- reactive({
    read.csv("/home/sebastiand/Dropbox/grants_jobs/vaxpox/toy_metadata.csv", stringsAsFactors = FALSE)
  })

  # Load sample data when button clicked
  observeEvent(input$load_btn, {
    if (input$load_sample != "") {
      data <- toy_data()
      selected <- data[data$sample_id == input$load_sample, ]

      if (nrow(selected) > 0) {
        updateTextInput(session, "sample_id", value = selected$sample_id[1])
        updateNumericInput(session, "birth_year", value = as.numeric(selected$birth_year[1]))
        updateSelectInput(session, "sex", selected = selected$sex[1])
        updateTextInput(session, "residence", value = selected$residence[1])
        updateDateInput(session, "symptom_date", value = as.Date(selected$symptom_date[1]))
        updateNumericInput(session, "num_lesions", value = as.numeric(selected$num_lesions[1]))
        updateSelectInput(session, "vaccination_status", selected = selected$vaccination_status[1])
        updateDateInput(session, "vaccination_date", value = if (selected$vaccination_date[1] != "") as.Date(selected$vaccination_date[1]) else NA)
        updateSelectInput(session, "previous_mpox", selected = selected$previous_mpox[1])
        updateSelectInput(session, "febrile_rash_history", selected = selected$febrile_rash_history[1])
        updateSelectInput(session, "underlying_conditions", selected = selected$underlying_conditions[1])
        updateTextInput(session, "profession", value = selected$profession[1])
        updateSelectInput(session, "contact_patients", selected = selected$contact_patients[1])
        updateSelectInput(session, "contact_animals", selected = selected$contact_animals[1])
        updateDateInput(session, "sampling_date", value = as.Date(selected$sampling_date[1]))
        updateSelectInput(session, "sample_type", selected = selected$sample_type[1])
        updateSelectInput(session, "pcr_result", selected = selected$pcr_result[1])
        updateNumericInput(session, "ct_value", value = as.numeric(selected$ct_value[1]))
      }
    }
  })

  # Calculate sequence statistics
  calculate_sequence_stats <- reactive({
    seq <- input$genome_sequence
    seq <- gsub("[^ATGCN]", "", toupper(seq))  # Remove non-sequence characters

    if (nchar(seq) == 0) {
      return(list(length = 0, gc = 0))
    }

    length <- nchar(seq)
    gc_count <- stringr::str_count(seq, "[GC]")
    gc_percent <- round((gc_count / length) * 100, 2)

    return(list(length = length, gc = gc_percent))
  })

  # Display sequence length
  output$seq_length_display <- renderText({
    stats <- calculate_sequence_stats()
    paste(stats$length, "bp")
  })

  # Display GC content
  output$gc_content_display <- renderText({
    stats <- calculate_sequence_stats()
    paste(round(stats$gc, 2), "%")
  })

  # Create summary table
  output$summary_table <- renderTable({
    data.frame(
      Field = c("Sample ID", "Country", "Birth Year", "Sex", "Place of Residence",
                "Symptom Onset", "Number of Lesions", "Sampling Date", "Sample Type",
                "PCR Result", "Ct Value", "Profession"),
      Value = c(input$sample_id, "TBD", input$birth_year, input$sex, input$residence,
                as.character(input$symptom_date), input$num_lesions, as.character(input$sampling_date),
                input$sample_type, input$pcr_result, input$ct_value, input$profession)
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  # Create sequence summary table
  output$sequence_summary_table <- renderTable({
    data.frame(
      Metric = c("Sequence Length (bp)", "GC Content (%)", "Valid Characters"),
      Value = c(calculate_sequence_stats()$length,
                calculate_sequence_stats()$gc,
                "Yes")
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  # Load and display phylogenetic tree
  output$tree_plot <- renderImage({
    tree_file <- "/home/sebastiand/Dropbox/grants_jobs/vaxpox/mpox_africa_genomes_aligned.fasta.treefile"

    if (file.exists(tree_file)) {
      tree <- ape::read.tree(tree_file)

      outfile <- tempfile(fileext = ".png")
      png(outfile, width = 900, height = 700, res = 100)
      plot(tree, main = "MPOX Phylogenetic Tree - African Isolates",
           cex = 0.8, edge.width = 2)
      axisPhylo()
      dev.off()

      list(src = outfile,
           contentType = "image/png",
           width = 900,
           height = 700,
           alt = "Phylogenetic tree")
    } else {
      NULL
    }
  }, deleteFile = TRUE)

  # Create JSON output
  output$json_output <- renderText({
    toJSON(list(
      sample = list(
        id = input$sample_id,
        demographic = list(
          birth_year = input$birth_year,
          sex = input$sex,
          residence = input$residence
        ),
        clinical = list(
          symptom_onset = as.character(input$symptom_date),
          num_lesions = input$num_lesions,
          vaccination_status = input$vaccination_status,
          previous_infection = input$previous_mpox,
          underlying_conditions = input$underlying_conditions
        ),
        epidemiological = list(
          profession = input$profession,
          contact_patients = input$contact_patients,
          contact_animals = input$contact_animals
        ),
        biological = list(
          sampling_date = as.character(input$sampling_date),
          sample_type = input$sample_type,
          pcr_result = input$pcr_result,
          ct_value = input$ct_value
        ),
        sequence = list(
          length = calculate_sequence_stats()$length,
          gc_content = calculate_sequence_stats()$gc
        )
      )
    ), pretty = TRUE)
  })

  # Download CSV
  output$download_csv <- downloadHandler(
    filename = function() {
      paste0("VAXPOX_", input$sample_id, "_metadata.csv")
    },
    content = function(file) {
      metadata <- data.frame(
        field = c("sample_id", "birth_year", "sex", "residence", "symptom_date",
                  "num_lesions", "vaccination_status", "previous_mpox", "underlying_conditions",
                  "profession", "contact_patients", "contact_animals", "sampling_date",
                  "sample_type", "pcr_result", "ct_value", "sequence_length", "gc_content"),
        value = c(input$sample_id, input$birth_year, input$sex, input$residence,
                  input$symptom_date, input$num_lesions, input$vaccination_status,
                  input$previous_mpox, input$underlying_conditions, input$profession,
                  input$contact_patients, input$contact_animals, input$sampling_date,
                  input$sample_type, input$pcr_result, input$ct_value,
                  calculate_sequence_stats()$length, calculate_sequence_stats()$gc)
      )
      write.csv(metadata, file, row.names = FALSE)
    }
  )

  # Download FASTA
  output$download_fasta <- downloadHandler(
    filename = function() {
      paste0("VAXPOX_", input$sample_id, ".fasta")
    },
    content = function(file) {
      seq <- gsub("[^ATGCN]", "", toupper(input$genome_sequence))
      fasta_content <- paste0(">", input$sample_id, "\n", seq)
      writeLines(fasta_content, file)
    }
  )
}

# Run the app
shinyApp(ui, server)
