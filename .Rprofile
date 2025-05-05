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

# palette
.colors = c(
  '#000000',
  '#307098',
  '#832211',
  '#b26925'
)

.shapes = c(
  15,
  16,
  17,
  18,
  19,
  20
)

.lazy = new.env()

decl_lazy <- function(name, pkgs, def) {
  .lazy[[name]] <- list(
    pkgs = pkgs,
    def  = def
  )
}

decl_lazy('draw_load', c('ggplot2'),
  function(name,
           trans = FALSE,
           rows  = NULL,
           cols  = NULL) {
    data <- read.table(name,
                       header = FALSE,
                       sep    = '\t')

    if (trans)
      data <- t(data)

    if (is.null(cols))
      cols <- as.character(1:ncol(data))

    names(data) <- cols

    if (is.null(rows))
      names(data)[1] <- 'x'
    else
      cbind(x = rows, data)

    # convert to long format
    plot <- tidyr::pivot_longer(data,
                                cols      = !x,
                                names_to  = 'cat',
                                values_to = 'val')

    return(ggplot(plot,
                  aes(x     = x,
                      y     = val,
                      color = cat,
                      shape = cat,
                      size  = cat,
                      fill  = cat)))
  }
)

decl_lazy('draw_with', c('ggplot2'),
  function(xlabel      = waiver(),
           ylabel      = waiver(),
           xlimit      = NULL,
           ylimit      = NULL,
           xlog        = FALSE,
           ylog        = FALSE,
           xticks      = waiver(),
           yticks      = waiver(),
           xminorticks = waiver(),
           yminorticks = waiver(),
           xticklabels = waiver(),
           yticklabels = waiver(),
           colors      = NULL,
           shapes      = NULL,
           sizes       = NULL,
           fills       = NULL) {

    mod <- list()

    if (xlog)
      mod <- append(mod,
                    scale_x_log10     (name         = xlabel,
                                       breaks       = xticks,
                                       minor_breaks = xminorticks,
                                       labels       = xticklabels,
                                       limits       = xlimit,
                                       guide        = guide_axis(minor.ticks = TRUE),
                                       oob          = scales::oob_keep))
    else
      mod <- append(mod,
                    scale_x_continuous(name         = xlabel,
                                       breaks       = xticks,
                                       minor_breaks = xminorticks,
                                       labels       = xticklabels,
                                       limits       = xlimit,
                                       guide        = guide_axis(minor.ticks = TRUE),
                                       oob          = scales::oob_keep))

    if (ylog)
      mod <- append(mod,
                    scale_y_log10     (name         = ylabel,
                                       breaks       = yticks,
                                       minor_breaks = yminorticks,
                                       labels       = yticklabels,
                                       limits       = ylimit,
                                       guide        = guide_axis(minor.ticks = TRUE),
                                       oob          = scales::oob_keep))
    else
      mod <- append(mod,
                    scale_y_continuous(name         = ylabel,
                                       breaks       = yticks,
                                       minor_breaks = yminorticks,
                                       labels       = yticklabels,
                                       limits       = ylimit,
                                       guide        = guide_axis(minor.ticks = TRUE),
                                       oob          = scales::oob_keep))

    mod <- append(mod,
                  scale_color_manual(values =
                    if (is.null(colors)) .colors else colors))

    mod <- append(mod,
                  scale_shape_manual(values =
                    if (is.null(shapes)) .shapes else shapes))

    if (!is.null(sizes))
      mod <- append(mod,
                    scale_size_manual(values = sizes))

    if (!is.null(fills))
      mod <- append(mod,
                    scale_fill_manual(values = fills))

    return(mod)
  }
)

decl_lazy('draw_lite', c('ggplot2'),
  function(aspect      =  0.4,
           text_margin =  0.01,
           font_name   = 'Linux Libertine',
           font_size   =  12,
           line_width  =  0.25,
           tick_major  =  0.025,
           tick_minor  =  0.0125,
           lkey_height =  0.1,
           lkey_width  =  0.3,
           lkey_sep    =  0.15,
           plot_margin =  0.0,
           units       = 'inches') {

    def_null <- element_blank()

    def_line <- element_line(linewidth     =  line_width,
                             linetype      = 'solid',
                             lineend       =  NULL,
                             color         = 'black',
                             arrow         =  NULL,
                             inherit.blank =  TRUE)

    def_rect <- element_rect(fill          =  NA,
                             linewidth     =  line_width,
                             linetype      = 'solid',
                             color         = 'black',
                             inherit.blank =  TRUE)

    def_text <- element_text(family        =  font_name,
                             face          = 'plain',
                             size          =  font_size,
                             hjust         =  0.5,
                             vjust         =  0.5,
                             angle         =  0,
                             lineheight    =  NULL,
                             color         = 'black',
                             margin        =  margin(t    = text_margin,
                                                     b    = text_margin,
                                                     l    = text_margin * 3,
                                                     r    = text_margin * 3,
                                                     unit = units),
                             debug         =  FALSE,
                             inherit.blank =  TRUE)

    def_text_ytitle <- def_text
    def_text_ylabel <- def_text
    def_rect_border <- def_rect

    def_tick_major  <- unit(tick_major,  units)
    def_tick_minor  <- unit(tick_minor,  units)

    def_lkey_height <- unit(lkey_height, units)
    def_lkey_width  <- unit(lkey_width,  units)
    def_lkey_sep    <- unit(lkey_sep,    units)

    def_unit_zero   <- unit(0.0,         units)

    def_marg_zero   <- margin(unit = units)
    def_marg_plot   <- margin(plot_margin,
                              plot_margin,
                              plot_margin,
                              plot_margin,
                              unit = units)

    def_text_ytitle$angle     <- 90
    def_text_ylabel$hjust     <- 1.0
    def_rect_border$linewidth <- line_width * 2

    return(theme(line                    =  def_line,
                 rect                    =  def_rect,
                 text                    =  def_text,
                 title                   =  def_text,
                 aspect.ratio            =  aspect,
                 axis.title              =  def_text,
                 axis.title.y            =  def_text_ytitle,
                 axis.text               =  def_text,
                 axis.text.y             =  def_text_ylabel,
                 axis.ticks              =  def_line,
                 axis.ticks.length       =  def_tick_major,
                 axis.minor.ticks.length =  def_tick_minor,
                 legend.margin           =  def_marg_zero,
                 legend.spacing          =  def_lkey_height,
                 legend.key.size         =  def_unit_zero,
                 legend.key.height       =  def_lkey_height,
                 legend.key.width        =  def_lkey_width,
                 legend.key.spacing      =  def_lkey_sep,
                 legend.text             =  def_text,
                 legend.text.position    = 'right',
                 legend.title            =  def_null,
                 legend.position         = 'top',
                 legend.direction        = 'horizontal',
                 legend.byrow            =  TRUE,
                 legend.location         = 'panel',
                 legend.box              = 'horizontal',
                 legend.box.just         = 'top',
                 legend.box.margin       =  def_marg_zero,
                 legend.box.spacing      =  def_tick_major,
                 panel.background        =  def_null,
                 panel.border            =  def_rect_border,
                 panel.spacing           =  def_unit_zero,
                 panel.grid              =  def_null,
                 panel.ontop             =  TRUE,
                 plot.tag                =  def_null,
                 plot.margin             =  def_marg_plot,
                 strip.background        =  def_null,
                 strip.clip              = 'inherit',
                 strip.placement         = 'inside',
                 strip.text              =  def_text,
                 strip.switch.pad.grid   =  def_unit_zero,
                 strip.switch.pad.wrap   =  def_unit_zero,
                 complete                =  TRUE,
                 validate                =  TRUE))
  }
)

decl_lazy('draw_save', c('ggplot2'),
  function(name,
           plot,
           device =  cairo_pdf,
           width  =  3.35,
           height =  1.75,
           units  = 'in',
           dpi    =  72) {

    ggsave(name,
           plot,
           device =  device,
           width  =  width,
           height =  height,
           units  =  units,
           dpi    =  dpi)
  }
)

load_lazy <- function() {
  for (name in ls(.lazy)) {
    f = .lazy[[name]]

    for (pkg in f$pkgs)
      library(pkg, character.only = TRUE)

    assign(name, f$def, envir = .GlobalEnv)
  }
}
