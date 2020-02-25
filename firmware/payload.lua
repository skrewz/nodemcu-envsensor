local M
do
  local self = {
  }

  local early = function()
    print("\n====================\nPlaceholder\n====================\nThis gets executed before wifi is established\n====================")
  end

  local main = function()
    print("\n====================\nPlaceholder\n====================\nThis gets executed once wifi is established\n====================")
  end

  -- expose
  M = {
    early = early,
    main = main,
  }
end
return M
