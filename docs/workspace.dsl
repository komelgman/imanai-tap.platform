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
            mq = --async-> {
                technology "Kafka/Redis Streams"
            }
            stream = --async-> {
                technology "Kafka Streams"
            }

            publicApi = container {
                technology "Java/Spring Boot"
                tag "Public Service"
            }

            privateApi = container {
                technology "Java/Spring Boot"
                tag "Internal Service"
            }

            datasource = container {
                tag "Internal Service"
            }
        }

        customer = person "Analytics User" "A person who accesses the TAP" "Customer"

        marketDataSource = softwaresystem "Market Data Source" "An external system that supplies real-time and historical market data." "External System"

        group "Imanai TAP" {
            dataManager = person "Data Manager" "A person who manage actual data info" "Staff"

            referenceDataSystem = softwaresystem "Reference Data System" "" {
                !adrs reference-data-system/adr
                !docs reference-data-system/docs

                instrumentRegistry = publicApi "Instrument Registry" "Provide instrument reference data"
                instrumentRegistryDB = datasource "Instrument Registry DB" "" "PostgreSQL" "Database"
                instrumentRegistryCache = datasource "Instrument Registry Cache" "" "Redis" "Cache"
                instrumentRegistryUpdater = privateApi "Instrument Registry Updater" "Updates data automatically"
            }

            marketDataSystem = softwaresystem  "Market Data System" "Provide market data streams (live, replay, transformed, combined)" {
                !adrs market-data-system/adr
                !docs market-data-system/docs

                group "Live Data flow" {
                    feedAdaptor = privateApi "Feed Adaptor" "Provider-specific adaptor (operates with messages)"
                    feedIngestor = privateApi "Feed Ingestor" "Operates with provider agnostic messages and combines it into streams (data quality gate)"
                }

                group "Historical Data Flow" {
                    historicalDataLoader = privateApi "Historical Data Loader" "Provider-specific loader/adaptor" "Spring Boot App" "Internal Service"
                    historicalDataService = privateApi "Historical Data Service" "Operate with collected immutable market data" "Spring Boot App" "Internal Service"
                    historicalDataStore = datasource "Historical Data Store" "Immutable finalized data" "S3 / Parquet / ClickHouse" "Database"
                }

                streamConfigurtaionStore = datasource "Stream Configuration Store" "User-specific stream configuration store" "" "Database"
                unifiedStreamProvider = publicApi "Unified Stream Provider" "Combines live/historical data to live/replay streams"
            }

            visualizationSystem = softwaresystem "Visualization" {

            }

            administrationSystem = softwaresystem "Administration System" "System administartion (users, instruments, ...)" {

            }

            strategyEngine = softwaresystem "Strategy Engine" {

            }   
        }

        /*
            Альтернативы:
            Если нужен технический стиль: “Reads/Writes”, “Publishes/Consumes”, “Fetches”, “Persists”.
            Если важно направление: “Provides”, “Requests”, “Supplies”.
            Если это межсервисная API-коммуникация: “Calls”, “Invokes”, “Subscribes to”.

            Рекомендации:
            Определи единый глагольный словарь: например, для хранилища всегда “Stores” / “Reads”, для API — “Calls”, для потоков — “Publishes/Consumes”.
            Проверяй связь: глагол должен отражать факт взаимодействия, а не бизнес-логику.
            Смотри на симметрию: если один компонент “Sends”, другой должен “Receives/Consumes”.        
        */

        customer -> visualizationSystem "Works with"
        dataManager -> administrationSystem "Works with"

        administrationSystem -> instrumentRegistry "Updates manualally"
        visualizationSystem -> unifiedStreamProvider "Uses"
        visualizationSystem -> instrumentRegistry "Uses"
        visualizationSystem -> strategyEngine "Uses"
        strategyEngine -> instrumentRegistry "Uses"
        strategyEngine -> unifiedStreamProvider "Uses"
        marketDataSystem -> instrumentRegistry "Uses"
        marketDataSystem -> marketDataSource "Uses"

        feedAdaptor --websocket-> marketDataSource "Handles feed"    
        historicalDataLoader -> marketDataSource "Requests historical data for instruments"

        feedAdaptor --gRPC-> instrumentRegistry "Uses"
        historicalDataLoader --gRPC-> instrumentRegistry "Uses"

        unifiedStreamProvider -> streamConfigurtaionStore "Uses"
        feedAdaptor --mq-> feedIngestor "Sends unified data"
        unifiedStreamProvider --stream-> feedIngestor "Consumes data streams and builds the last bar for each open period"    

        historicalDataService --gRPC-> historicalDataLoader "Pulls unified historical data"
        historicalDataService -> historicalDataStore "Stores data"
        unifiedStreamProvider -> historicalDataService "Uses collected historical data"

        instrumentRegistry -> instrumentRegistryDB "Stores data"
        instrumentRegistry -> instrumentRegistryCache "Caches data"
        instrumentRegistryUpdater -> marketDataSource "Scrapes data"
        instrumentRegistryUpdater -> instrumentRegistry "Updates automatically"
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

        container marketDataSystem "MarketDSContainers" {
            include *
        }

        container referenceDataSystem "ReferenceDSContainers" {
            include *
        }

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
