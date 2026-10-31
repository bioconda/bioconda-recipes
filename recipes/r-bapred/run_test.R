suppressPackageStartupMessages(library(bapred))

set.seed(1)
expression <- matrix(rnorm(240), nrow = 12)
batch <- factor(rep(1:2, each = 6))
expression[batch == 2, ] <- expression[batch == 2, ] + 2
fit <- combatba(expression, batch)
stopifnot(
    inherits(fit, "combat"), identical(dim(fit$xadj), dim(expression)),
    all(is.finite(fit$xadj)), !identical(fit$xadj, expression),
    identical(combatba(expression, factor(rep(1, 12)))$xadj, expression)
)
p_value <- fuzzywilcox(c(1, 2, 2, 4, 2, 3, 5, 6), factor(rep(1:2, each = 4)))
stopifnot(is.finite(p_value), p_value >= 0, p_value <= 1)
