-- Adds anchor links to headings with IDs.
function Header (h)
  if h.identifier ~= '' then
    local anchor_link = pandoc.Link(
      {pandoc.Str '🔗'},   -- content
      '#' .. h.identifier, -- href
      '',                  -- title
      {}                   -- attributes
    )
    h.content:insert(1, anchor_link)
    return h
  end
end
