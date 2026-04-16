module MessagesHelper
  def message_status_icon(message)
    case message.status
    when "pending"
      tag.svg(viewBox: "0 0 16 16", class: "wa-tick", "aria-label": "pending") do
        tag.path(d: "M8 3v5l3 2", fill: "none", stroke: "currentColor", "stroke-width": 1.5, "stroke-linecap": "round") +
          tag.circle(cx: 8, cy: 8, r: 6, fill: "none", stroke: "currentColor", "stroke-width": 1.5)
      end
    when "sent"
      tag.svg(viewBox: "0 0 16 12", class: "wa-tick", "aria-label": "sent") do
        tag.path(d: "M1 7 L5.5 11 L15 1", fill: "none", stroke: "currentColor",
                 "stroke-width": 1.6, "stroke-linecap": "round", "stroke-linejoin": "round")
      end
    when "delivered", "read"
      tag.svg(viewBox: "0 0 20 12", class: "wa-tick wa-tick--double", "aria-label": message.status) do
        tag.path(d: "M1 7 L5 11 L13 1", fill: "none", stroke: "currentColor",
                 "stroke-width": 1.6, "stroke-linecap": "round", "stroke-linejoin": "round") +
          tag.path(d: "M7 11 L11 7 M9 11 L19 1", fill: "none", stroke: "currentColor",
                   "stroke-width": 1.6, "stroke-linecap": "round", "stroke-linejoin": "round")
      end
    when "failed"
      tag.svg(viewBox: "0 0 16 16", class: "wa-tick wa-tick--failed", "aria-label": "failed") do
        tag.circle(cx: 8, cy: 8, r: 7, fill: "none", stroke: "currentColor", "stroke-width": 1.6) +
          tag.path(d: "M8 4v5 M8 11.5v.5", stroke: "currentColor", "stroke-width": 1.8, "stroke-linecap": "round")
      end
    end
  end
end
