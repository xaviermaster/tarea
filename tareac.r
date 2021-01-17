if(!require(tidyverse)) {install.packages("tidyverse")}
if(!require(openxlsx)) {install.packages("openxlsx")}
if(!require(dplyr)) {install.packages("dplyr")}
if(!require(modelr)) {install.packages("modelr")}
library("tidyverse")
library("openxlsx")
library("dplyr")
library("modelr")
#carga de datos
publicidad <- read_csv("https://raw.githubusercontent.com/jorgeklz/curso-utm/main/publicidad.csv")
publicidad
publicidad %>%
  filter(PUBLICIDAD_TOTAL < 2000) %>%
  ggplot(aes(x=PUBLICIDAD_TOTAL, y=VISITAS_MILES)) +
  geom_point(aes(color= USA_FAMOSO), alpha=0.5) +
  labs(title= 'Visitas recibidas según gasto en publicidad',
       x='Gasto (dólares) en publicidad', y= 'Visitas (miles)') +
  theme(legend.position="bottom")
# fijar semilla. Con esto garantizamos que los experimentos sean reproducibles
set.seed(1987)
# generar 70% de números aleatorios
id <- sample(1:nrow(publicidad), nrow(publicidad)*.70)
# crear el conjunto de entrenamiento
ds_entrenamiento <- publicidad[id,]
head(ds_entrenamiento)
# crear el conjunto de prueba
ds_prueba <- publicidad[-id,]
head(ds_prueba)
# Realiza una regresión lineal simple: y ~ x
rl_simple <- ds_entrenamiento %>%
  lm(VISITAS_MILES ~ PUBLICIDAD_TOTAL, data=.)
# Ver resumen de resultados
summary(rl_simple)
PUBLICIDAD_TOTAL <- 2000
as.data.frame(PUBLICIDAD_TOTAL) %>%
  add_predictions(rl_simple, var = 'PREDICCION_VISITAS (miles)')
# Generar la predicción a partir del conjunto de prueba
ds_prediccion <- ds_prueba %>%
  select(PUBLICIDAD_TOTAL) %>%
  add_predictions(rl_simple, var = 'PREDICCION')
# Se agregan las predicciones al conjunto de prueba
ds_prueba$PREDICCION <- ds_prediccion$PREDICCION
# Se grafican los errores
ds_prueba %>%
  ggplot(aes(x= PUBLICIDAD_TOTAL, y= VISITAS_MILES)) +
  # generamos lineas de errores
  geom_segment(aes(xend = PUBLICIDAD_TOTAL, yend = PREDICCION), color= "gray") +
  # agregamos los puntos que representan las instancias
  geom_point() +
  # creamos la línea de regresión
  geom_line(aes(y= PREDICCION), colour = "red", size = 1) +
  ggtitle("Errores de predicción")
#error cuadratico medio
errores <- sqrt(sum((ds_prueba$VISITAS_MILES - ds_prueba$PREDICCION)^2)/(nrow(ds_prueba)))
errores
#MULTIPLE
# Convierte a binario
publicidad <- publicidad %>%
  mutate(USA_FAMOSO_NUM = ifelse(USA_FAMOSO=="SI", 1, 0))
# fijar semilla. Con esto garantizamos que los experimentos sean reproducibles
set.seed(1987)
# generar 70% de números aleatorios
id <- sample(1:nrow(publicidad), nrow(publicidad)*.70)
# crear el conjunto de entrenamiento
ds_entrenamiento <- publicidad[id,]
# crear el conjunto de prueba
ds_prueba <- publicidad[-id,]
# Aplica regresión múltiple
rl_multiple <- ds_entrenamiento %>%
  lm(VISITAS_MILES ~ PUBLICIDAD_TOTAL + USA_FAMOSO_NUM, data=.)
# Ver resumen de resultados
summary(rl_multiple)
PUBLICIDAD_TOTAL <- c(1500, 1500)
USA_FAMOSO_NUM <- c(1, 0)
as_data_frame(cbind(PUBLICIDAD_TOTAL, USA_FAMOSO_NUM)) %>%
  add_predictions(rl_multiple, var = 'PREDICCION_VISITAS (miles)')

