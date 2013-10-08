invisible(lapply(c("topicmodels", "ggplot2", "maps", "plyr",
                   "mapproj", "grid"), require, character.only = TRUE))

map.theme <- function() {
  theme_bw() + theme(axis.line = element_blank(),
                     axis.text.x = element_blank(), axis.text.y = element_blank(),
                     axis.title.x = element_blank(), axis.title.y = element_blank(),
                     axis.ticks = element_blank(), panel.border = element_blank(),
                     panel.grid.major = element_blank(), plot.margin = unit(c(.1, .1, .1, .1), "in"))
}

df <- read.csv("statement_data.csv")
df$county <- tolower(df$county)

pop <- read.csv("population_data.csv", header = FALSE)[-c(1:3), ]
names(pop) <- c("county", "2010", "2011", "2012")
pop$county <- tolower(gsub(" County", "", pop$county))
pop[, c(2:4)] <- apply(pop[, c(2:4)], 2, function(x) as.integer(gsub(",", "", x)))
pop$pop.mean <- apply(pop[, c(2:4)], 1, function(x) mean(x))
pop <- pop[, c(1,5)]
df <- merge(df, pop)

p <- ggplot(df, aes(x = race))
p <- p + geom_bar()
p <- p + labs(x = "Race", y = "Count",
              title = "Race of Executed Prisoners in Texas 1982-2013")
p <- p + theme_bw()

p <- ggplot(df, aes(x = age))
p <- p + geom_density(fill = "black")
p <- p + labs(x = "Age", y = "Density",
              title = "Age of Executed Prisoners in Texas 1982-2013")
p <- p + theme_bw()

state.df <- ddply(df, .(county), nrow)
state.df <- merge(state.df, pop)
names(state.df) <- c("subregion", "executions", "pop.mean")
texas.map <- map_data("county")
texas.map <- texas.map[texas.map$region == "texas", ]
texas.map <- merge(texas.map, state.df, all.x = TRUE, sort = FALSE)
texas.map$executions[is.na(texas.map$executions)] <- 0
texas.map$pop.mean[is.na(texas.map$pop.mean)] <- 1 #executions per cap will be 0 anyhow
texas.map$executions.percap <- texas.map$executions / texas.map$pop.mean
texas.map <- texas.map[order(texas.map$order), ]

p <- ggplot(data = texas.map, aes(x = long, y = lat, group = group))
p <- p + geom_polygon(aes(fill = executions))
p <- p + scale_fill_gradient(low = "white", high = "red",
                             name = "Executions")
p <- p + geom_path(data = texas.map, colour = "gray")
p <- p + labs(title = "Total Executions by County, 1982-2013", x = NULL, y = NULL)
p <- p + coord_map()
p <- p + map.theme()

p <- ggplot(data = texas.map, aes(x = long, y = lat, group = group))
p <- p + geom_polygon(aes(fill = executions.percap))
p <- p + scale_fill_gradient(low = "white", high = "red",
                             name = "Executions per Capita")
p <- p + geom_path(data = texas.map, colour = "gray")
p <- p + labs(title = "Executions per Capita by County, 1982-2013", x = NULL, y = NULL)
p <- p + coord_map()
p <- p + map.theme()
