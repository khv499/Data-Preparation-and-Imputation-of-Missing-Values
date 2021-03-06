# The aim of this lesson is to eliminate missing values in a data set before the creation of a Naive Bayes classifier
# We will try to predict academics' intention to use Wikipedia, i.e.
# BI1: In the future I will recommend the use of Wikipedia to my colleagues and students
# BI2: In the future I will use Wikipedia in my teaching activity

# Define your working directory
setwd("C:/Users/admin/Documents/Data Preparation and Imputation of Missing Values")
getwd()

# Install these packages first if working on your computer
# To use cor.ci in psych, nb and confusionMatrix in caret, impute in Hmisc
install.packages(c("psych", "e1071", "caret", "Hmisc"), dependencies = TRUE)
library("psych")
library("caret")
library("Hmisc")

# Read all of the Wiki4HE questionnaire responses and explore the data
wiki4he <- read.csv("Data/wiki4HE.csv", sep = ";", na.strings = "?")

# Set the target var, select one
will.use.wiki <- wiki4he$BI1         # Recommendation to use by colleagues and students
will.use.wiki <- wiki4he$BI2         # Recommendation to use in teaching

# Select candidate predictors
age <- wiki4he$AGE                   # Numeric
gender <- wiki4he$GENDER             # 0=Male; 1=Female
domain <- wiki4he$DOMAIN             # 1=Arts&Hum; 2=Sci; 3=Health; 4=Eng&Arch; 5=Law&Politics
phd <- wiki4he$PhD                   # 0=No; 1=Yes
years.exp <- wiki4he$YEARSEXP        # Numeric
univ <- wiki4he$UNIVERSITY           # 1=UOC; 2=UPF
uoc.pos <- wiki4he$UOC_POSITION      # 1=Prof; 2=Assoc; 3=Assist; 4=Lect; 5=Instr; 6=Adj
other.pos <- wiki4he$OTHER_POSITION  # 1=Yes; 2=No (main job elswhere)
other.status <- wiki4he$OTHERSTATUS  # 1=Prof; 2=Assoc; 3=Assist; 4=Lect; 5=Instr; 6=Adj
user.wiki <- wiki4he$USERWIKI        # 0=No; 1=Yes
# All below: 1=S.Disagree..5=S.Agree
wiki.user.friendly <- wiki4he$PEU1   # Wiki perceived user friendly
wiki.easy.to.find <- wiki4he$PEU2    # Wiki easy to find info
wiki.easy.to.edit <- wiki4he$PEU3    # Wiki easy to add and edit
wiki.easy.use <- wiki4he$PU1         # Wiki easy for students
wiki.improves.learn <- wiki4he$PU2   # Wiki improves learning
wiki.useful.teach <- wiki4he$PU3     # Wiki useful for teaching
wiki.stimulates <- wiki4he$ENJ1      # Wiki stimulates curiosity
wiki.entertains <- wiki4he$ENJ2      # Wiki is entertaining to use
wiki.reliable <- wiki4he$Qu1         # Wiki is reliable
wiki.uptodate <- wiki4he$Qu2         # Wiki is up to date
wiki.comprehensive <- wiki4he$Qu3    # Wiki is comprehensive
wiki.low.quality <- wiki4he$Qu4      # Wiki is lower quality than others
wiki.trust.editors <- wiki4he$Qu5    # I trust in the editing system

# Let us look at the variables to consider their relationship
wb <- data.frame(age, gender, domain, phd,
                 years.exp, univ, uoc.pos,
                 other.status, user.wiki, wiki.user.friendly, 
                 wiki.easy.to.find, wiki.easy.to.edit,
                 wiki.easy.use, wiki.improves.learn, 
                 wiki.useful.teach, wiki.stimulates,
                 wiki.entertains, wiki.reliable,
                 wiki.uptodate, wiki.comprehensive,
                 wiki.low.quality, wiki.trust.editors,
                 will.use.wiki)

# Spearman: rank corr, non-param, degree of assoc, ordinal, no assumpt
cor.ci(wb, method="spearman")

##### Eliminate vars that are not promising, i.e.
#     gender, domain, age, phd, years.exp, other.status, univ, uoc.pos
#     wiki.user.friendly, wiki.entertains, wiki.low.quality
#
#     Eliminate vars that are inter-dependent, i.e.
#     wiki.easy.use, wiki.improves.learn
#     wiki.entertains, wiki.uptodate, wiki.comprehensive

wb <- data.frame(user.wiki, 
                 wiki.easy.to.find, wiki.easy.to.edit,
                 wiki.useful.teach, wiki.stimulates,
                 wiki.reliable,
                 will.use.wiki)

cor.ci(wb, method="spearman")

##### Too many variables so we'll do this is two stages
#     Add more variables

wiki.well.considered <- wiki4he$Im1    # Wiki is well considered among colleagues
wiki.sharing.apprec <- wiki4he$Im2     # Wiki sharing is appreciated
wiki.colleagues.use.it <- wiki4he$Im3   # My colleagues use it
wiki.imp.to.share <- wiki4he$SA1       # Wiki important to share with academics
wiki.imp.to.publish <- wiki4he$SA2     # Wiki important to publish on
wiki.imp.to.collab <- wiki4he$SA3      # Wiki important to collaborate
wiki.i.blog <- wiki4he$Pf1             # I write blogs
wiki.i.soc.net <- wiki4he$Pf2          # I participate in soc nets
wiki.open.publish <- wiki4he$Pf3       # I publish in open platforms
wiki.uni.open.collab <- wiki4he$JR1    # My university promotes open collabs
wiki.uni.gives.merit <- wiki4he$JR2    # My university gives merit for using it
wiki.use.dev.teach <- wiki4he$Use1     # I use wiki to develop my teaching
wiki.use.dev.acts <- wiki4he$Use2      # I use wiki to develop edu activities
wiki.recomm.studs <- wiki4he$Use3      # I recommend students use wiki
wiki.agree.studs <- wiki4he$Use5       # I agree students use wiki

wb <- data.frame(user.wiki, 
                 wiki.easy.to.find, wiki.easy.to.edit,
                 wiki.useful.teach, wiki.stimulates,
                 wiki.reliable, wiki.well.considered,
                 wiki.sharing.apprec, wiki.colleagues.use.it,
                 wiki.imp.to.share, wiki.imp.to.publish,
                 wiki.imp.to.collab, wiki.i.blog,
                 wiki.i.soc.net, wiki.open.publish,
                 wiki.uni.open.collab, wiki.uni.gives.merit,
                 wiki.use.dev.teach, wiki.use.dev.acts,
                 wiki.recomm.studs, wiki.agree.studs,
                 will.use.wiki)

cor.ci(wb, method="spearman")

##### Again eliminate vars that are less promising, i.e.
#     user.wiki, gender, domain, wiki.sharing.apprec
#     wiki.easy.to.find, wiki.easy.to.edit, wiki.imp.to.publish
#     wiki.uni.open.collab, wiki.i.blog, wiki.uni.gives.merit
#
#     Again eliminate vars that are inter-dependent, i.e.
#     wiki.imp.to.collab, wiki.imp.to.share, wiki.recomm.studs,
#     wiki.agree.studs
#
#     Optimise vars by keeping only the best, so removing:
#     wiki.stimulates, wiki.open.publish

wb <- data.frame(wiki.useful.teach,
                 wiki.reliable, 
                 wiki.well.considered,
                 wiki.colleagues.use.it,
                 wiki.use.dev.teach,
                 will.use.wiki)

cor.ci(wb, method="spearman")

# Remove missing values in the simplest way
# Many statistical models will fail with missing values
# Predict function will fail with missing values

# First prepare target to be a factor and see any NBs
# Initially define a target variable as is
wb$will.use.wiki <- factor(will.use.wiki)

# Later see if you can improve by reducing class levels
wb$will.use.wiki <- 
  factor(ifelse(will.use.wiki < 3, "Disagree", 
                ifelse(will.use.wiki > 3, "Agree", "Neutral")))

# Check which variables have missing values
summary(wb)

# Remove missing values from the target var - delete all observations
wb <- subset(wb, !is.na(will.use.wiki))

# Replace all missing values in numeric vars with the mean
# Replace all missing values in categorical vars with the median
# Note that the only numeric var age has no NAs
wb$wiki.useful.teach <- as.numeric(impute(wb$wiki.useful.teach, median))
wb$wiki.reliable <- as.numeric(impute(wb$wiki.reliable, median))
wb$wiki.well.considered <- as.numeric(impute(wb$wiki.well.considered, median))
wb$wiki.colleagues.use.it <- as.numeric(impute(wb$wiki.colleagues.use.it, median))
wb$wiki.use.dev.teach <- as.numeric(impute(wb$wiki.use.dev.teach, median))
summary(wb)

# Run Naive-Bayes in cross-validation loop with honest testing
set.seed(2016)

wb.size <- length(wb$will.use.wiki)
wb.train.size <- round(wb.size * 0.75) # 75% for training
wb.test.size <- wb.size - wb.train.size # The rest for testing
wb.train.idx <- sample(seq(1:wb.size), wb.train.size) # Indeces for training
wb.train.sample <- wb[wb.train.idx,]
wb.test.sample <- wb[-wb.train.idx,]

# Run NB with cross-validation
set.seed(2016)
train_control <- trainControl(method="cv", number=10)
tune.grid <- data.frame(.fL=0, .usekernel=FALSE, .adjust=1)
nb.model <- train(will.use.wiki~., 
                  data=wb.train.sample, trControl=train_control, method="nb",
                  tuneGrid=tune.grid)
print(nb.model)

### Do honest testing, unless all missing values are removed we'll get errors!
preds <- predict(nb.model, 
                 subset(wb.test.sample, select = -will.use.wiki))
confusionMatrix(table(preds, wb.test.sample$will.use.wiki))
