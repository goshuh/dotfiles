.libPaths('~/.r')

# these functions should be built-in
pkg_remove <- function(pkg) {
  ins <- installed.packages()
  all <- tools::package_dependencies(rownames(ins), ins, recursive = TRUE)

  dep <- if (is.null(all[[pkg]])) character() else all[[pkg]]
  use <- unique(unlist(all[!names(all) %in% c(pkg, dep)]))
  rem <- dep[!dep %in% use]

  if (length(rem))
    print(rem)
}

pkg_orphan <- function() {
  ins <- installed.packages()
  all <- tools::package_dependencies(rownames(ins), ins, recursive = TRUE)

  # filter out built-in packages
  print(setdiff(rownames(ins[grepl('/.r', ins[, 'LibPath'], fixed = TRUE), ]),
                unique(unlist(all))))
}
