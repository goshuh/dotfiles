.libPaths("~/.r")

library(ggplot2)

draw_lite <- function(
  val_aspect      =  0.4,
  val_text_margin =  0.01,
  val_font_name   = "Linux Libertine",
  val_font_size   =  12,
  val_line_width  =  0.25,
  val_tick_major  =  0.025,
  val_tick_minor  =  0.0125,
  val_lkey_height =  0.1,
  val_lkey_width  =  0.3,
  val_lkey_sep    =  0.15,
  val_unit        = "inches") {

  def_null <- element_blank()

  def_line <- element_line(linewidth     =  val_line_width,
                           linetype      = "solid",
                           lineend       =  NULL,
                           color         = "black",
                           arrow         =  NULL,
                           inherit.blank =  TRUE)

  def_rect <- element_rect(fill          =  NA,
                           linewidth     =  val_line_width,
                           linetype      = "solid",
                           color         = "black",
                           inherit.blank =  TRUE)

  def_text <- element_text(family        =  val_font_name,
                           face          = "plain",
                           size          =  val_font_size,
                           hjust         =  0.5,
                           vjust         =  0.5,
                           angle         =  0,
                           lineheight    =  NULL,
                           color         = "black",
                           margin        =  margin(t    = val_text_margin,
                                                   b    = val_text_margin,
                                                   l    = val_text_margin * 3,
                                                   r    = val_text_margin * 3,
                                                   unit = val_unit),
                           debug         =  FALSE,
                           inherit.blank =  TRUE)

  def_text_ytitle <- def_text
  def_text_ylabel <- def_text

  def_tick_major  <- unit(val_tick_major,  val_unit)
  def_tick_minor  <- unit(val_tick_minor,  val_unit)

  def_lkey_height <- unit(val_lkey_height, val_unit)
  def_lkey_width  <- unit(val_lkey_width,  val_unit)
  def_lkey_sep    <- unit(val_lkey_sep,    val_unit)

  def_unit_zero   <- unit(0.0,             val_unit)

  def_marg_zero   <- margin(0.0, 0.0, 0.0, 0.0, unit = val_unit)

  def_text_ytitle$angle <- 90
  def_text_ylabel$hjust <- 1.0

  return(theme(line                    =  def_line,
               rect                    =  def_rect,
               text                    =  def_text,
               title                   =  def_text,
               aspect.ratio            =  val_aspect,
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
               legend.text.position    = "right",
               legend.title            =  def_null,
               legend.position         = "top",
               legend.direction        = "horizontal",
               legend.byrow            =  TRUE,
               legend.location         = "panel",
               legend.box              = "horizontal",
               legend.box.just         = "top",
               legend.box.margin       =  def_marg_zero,
               legend.box.spacing      =  def_tick_major,
               panel.background        =  def_null,
               panel.border            =  def_rect,
               panel.spacing           =  def_unit_zero,
               panel.grid              =  def_null,
               panel.ontop             =  TRUE,
               plot.tag                =  def_null,
               plot.margin             =  def_marg_zero,
               strip.background        =  def_null,
               strip.clip              = "inherit",
               strip.placement         = "inside",
               strip.text              =  def_text,
               strip.switch.pad.grid   =  def_unit_zero,
               strip.switch.pad.wrap   =  def_unit_zero,
               complete                =  TRUE,
               validate                =  TRUE))
}

draw_save <- function(
  name,
  plot,
  device =  cairo_pdf,
  width  =  3.35,
  height =  1.75,
  units  = "in",
  dpi    =  72) {

  ggsave(name,
         plot,
         device = device,
         width  = width,
         height = height,
         units  = units,
         dpi    = dpi)
}
