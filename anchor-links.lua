-- Adds anchor links to headings with IDs.
-- From <https://github.com/jgm/pandoc/issues/7907#issuecomment-1035136993>.
function Header (h)
  if h.identifier ~= '' then
    local anchor_link = pandoc.Link(
      {pandoc.Str '# '},   -- content
      '#' .. h.identifier, -- href
      '',                  -- title
      {}                   -- attributes
    )
    h.content:insert(1, anchor_link)
    return h
  end
end
