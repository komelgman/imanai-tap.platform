workspace "Imanai TAP" "Trading Analytics Portal" {
    !docs workspace-docs
    !adrs workspace-adrs

    model {
        properties {
            "structurizr.groupSeparator" "/"
        }

        archetypes {
            sync = -> {
                tags "Synchronous"
            }
            https = --sync-> {
                technology "HTTPS"
            }
            gRPC = --sync-> {
                technology "gRPC"
            }
            websocket = --sync-> {
                technology "Websocket"
            }
            async = -> {
                tags "Asynchronous"
            }
            eventBus = --async-> {
                technology "Kafka/Redis Streams"
            }
            stream = --async-> {
                technology "Kafka Streams etc"
            }
        }

        customer = person "Analytics User" "A person who accesses the TAP" "Customer"

        marketDataProvider = softwaresystem "Feed Provider" "An external system that supplies real-time and historical market data." "External System"

        group "Imanai TAP" {
            dataManager = person "Data Manager" "A person who manage actual data info (updates instruments meta etc)" "Staff"

            metaDataSystem = softwaresystem "Meta Data System" {
                instrumentRegistry = container "Instrument Registry" "Provide instrument meta data" "Spring Boot App" "Public Service"
                instrumentRegistryDB = container "Instrument Registry DB" "Stores instrument meta data" "PostgreSQL" "Database"
            }

            marketDataSystem = softwaresystem  "Market Data System" {
                // !adrs market-data-system/adr
                // !docs market-data-system/docs

                group "Live Data flow" {
                    feedAdaptor = container "Feed Adaptor" "Provider-specific adaptor (operates with messages)" "Spring Boot App" "Internal Service"
                    feedIngestor = container "Feed Ingestor" "Operates with provider agnostic messages and combines it into streams (data quality gate)" "Spring Boot App" "Internal Service"
                }

                group "Historical Data Flow" {
                    historicalDataLoader = container "Historical Data Loader" "Provider-specific loader/adaptor" "Spring Boot App" "Internal Service"
                    historicalDataService = container "Historical Data Service" "Operate with collected immutable market data" "Spring Boot App" "Internal Service"
                    historicalDataStore = container "Historical Data Store" "Immutable finalized data" "S3 / Parquet / ClickHouse" "Database,Internal Service"
                }

                streamProvider = container "Unified Stream Provider" "Combines live/historical data to live/replay streams" "Spring Boot App" "Public Service"
            }

            visualizationSystem = softwaresystem "Visualization System" {

            }

            administrationSystem = softwaresystem "Administration System" {

            }

            strategyEngine = softwaresystem "Strategy Engine" {

            }   
        }

        // Platform
        customer -> visualizationSystem "Work with"
        dataManager -> administrationSystem "Work with"

        administrationSystem -> instrumentRegistry "Uses/Updates"
        visualizationSystem -> streamProvider "Uses"
        visualizationSystem -> instrumentRegistry "Uses"
        visualizationSystem -> strategyEngine "Uses"
        strategyEngine -> instrumentRegistry "Uses"
        strategyEngine -> streamProvider "Uses"
        marketDataSystem -> instrumentRegistry "Uses"

        feedAdaptor --websocket-> marketDataProvider "Handle instrument feed"
        historicalDataLoader -> marketDataProvider "Request Historical Data for Instruments"

        // Market Data System
        feedAdaptor --eventBus-> feedIngestor "Streams unified data to Ingestor"
        streamProvider --stream-> feedIngestor "Uses streams to provide Last Bar for currently opened periods"
        
        historicalDataService --gRPC-> historicalDataLoader "Pull unified historical data"
        historicalDataService -> historicalDataStore "Store in"
        streamProvider -> historicalDataService "Uses collected historical data"

        instrumentRegistry -> instrumentRegistryDB
    }

    views {
        properties {
            "c4plantuml.elementProperties" "true"
            "c4plantuml.tags" "true"
            "generatr.style.colors.primary" "#485fc7"
            "generatr.style.colors.secondary" "#ffffff"
            "generatr.style.faviconPath" "site/favicon.ico"
            "generatr.style.logoPath" "site/logo.png"

            // Absolute URL's like "https://example.com/custom.css" are also supported
            "generatr.style.customStylesheet" "site/custom.css"

            "generatr.svglink.target" "_self"

            // Full list of available "generatr.markdown.flexmark.extensions"
            // "Abbreviation,Admonition,AnchorLink,Aside,Attributes,Autolink,Definition,Emoji,EnumeratedReference,Footnotes,GfmIssues,GfmStrikethroughSubscript,GfmTaskList,GfmUsers,GitLab,Ins,Macros,MediaTags,ResizableImage,Superscript,Tables,TableOfContents,SimulatedTableOfContents,Typographic,WikiLinks,XWikiMacro,YAMLFrontMatter,YouTubeLink"
            // see https://github.com/vsch/flexmark-java/wiki/Extensions
            // ATTENTION:
            // * "generatr.markdown.flexmark.extensions" values must be separated by comma
            // * it's not possible to use "GitLab" and "ResizableImage" extensions together
            // default behaviour, if no generatr.markdown.flexmark.extensions property is specified, is to load the Tables extension only
            "generatr.markdown.flexmark.extensions" "Abbreviation,Admonition,AnchorLink,Attributes,Autolink,Definition,Emoji,Footnotes,GfmTaskList,GitLab,MediaTags,Tables,TableOfContents,Typographic"

            "generatr.site.exporter" "structurizr"
            "generatr.site.externalTag" "External System"
            "generatr.site.nestGroups" "false"
            "generatr.site.cdn" "https://cdn.jsdelivr.net/npm"
            "generatr.site.theme" "auto"
        }

        systemlandscape "SystemLandscape" {
            include *
            autoLayout
        }

        systemcontext marketDataSystem "SystemContext" {
            include *
            autoLayout
            title "System Context of Market Data System"
            description "Describes the overall context"
        }

        container marketDataSystem "MDSContainers" {
            include *
        }

        # filtered "MDSContainers" exclude "Database"

        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "Customer" {
                background #686868
            }
            element "Staff" {
                background #08427B
            }
            element "Software System" {
                background #96bde4                
                color #ffffff
            }
            element "Internal Service" {
                background #1168bd
                opacity 75
                color #ffffff
            }            
            element "External System" {
                background #686868
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #1168bd
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #1168bd
                color #000000
            }
            element "Failover" {
                opacity 25
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Asynchronous" {
                dashed true
            }
        }
    }
}
