# Create default user
user = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin User"
  u.password = "password123456"
  u.verified = true
  u.role = :product_owner
end

puts "Created user: #{user.email}"

# Create ProductPlanner product (dogfooding)
product = Product.find_or_create_by!(slug: "product-planner") do |p|
  p.name = "ProductPlanner"
  p.description = "The product planning tool itself - tracking its own development"
end

# Add user as owner
Membership.find_or_create_by!(user: user, product: product) do |m|
  m.role = :owner
end

puts "Created product: #{product.name}"

# Create initial cards for Phase 1
cards_data = [
  { title: "Rails 8 setup with PostgreSQL, Tailwind, Hotwire", card_type: :task, stage: :done, priority: :high },
  { title: "User authentication with roles", card_type: :task, stage: :done, priority: :high },
  { title: "Core domain models", card_type: :task, stage: :done, priority: :high },
  { title: "Kanban board UI", card_type: :feature, stage: :build, priority: :high },
  { title: "Card drag-drop functionality", card_type: :task, stage: :build, priority: :medium },
  { title: "Card detail slide-over", card_type: :feature, stage: :definition, priority: :medium },
  { title: "Comments on cards", card_type: :feature, stage: :definition, priority: :low },
  { title: "Gate checklist enforcement", card_type: :feature, stage: :discovery, priority: :high },
  { title: "Scenarios (Given/When/Then)", card_type: :feature, stage: :discovery, priority: :medium },
  { title: "Activity log", card_type: :feature, stage: :definition, priority: :low },
  { title: "OKR integration", card_type: :feature, stage: :opportunity, priority: :medium },
  { title: "GitHub integration", card_type: :feature, stage: :opportunity, priority: :low },
  { title: "Shortcut integration", card_type: :feature, stage: :opportunity, priority: :low },
  { title: "AI Product Assistant", card_type: :feature, stage: :opportunity, priority: :medium }
]

cards_data.each do |card_data|
  card = Card.find_or_create_by!(product: product, title: card_data[:title]) do |c|
    c.owner = user
    c.card_type = card_data[:card_type]
    c.stage = card_data[:stage]
    c.priority = card_data[:priority]
    c.initialize_gate_checklist!
  end
  puts "  - Card: #{card.title} (#{card.stage})"
end

puts "\nSeed completed!"
puts "Login with: admin@example.com / password123456"
