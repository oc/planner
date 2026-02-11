class Card < ApplicationRecord
  include Trackable

  STAGES = %w[opportunity discovery definition feasibility commitment build validate operate done].freeze

  GATE_REQUIREMENTS = {
    opportunity: %w[named_customer stated_problem quantified_value okr_linked],
    discovery: %w[problem_statement success_criteria user_segments],
    definition: %w[scenarios_exist acceptance_criteria ui_direction],
    feasibility: %w[feasibility_assessment effort_estimate risks_identified],
    commitment: %w[scope_locked release_criteria support_plan],
    build: %w[implementation_complete criteria_verified docs_updated],
    validate: %w[customer_feedback success_measured okr_impact_measured],
    operate: %w[monitoring_active runbooks_created deprecation_criteria]
  }.freeze

  AUTO_GATES = {
    okr_linked: ->(card) { card.card_key_results.any? },
    scenarios_exist: ->(card) { card.scenarios.any? },
    okr_impact_measured: ->(card) { card.all_impacts_recorded? }
  }.freeze

  TYPE_COLORS = {
    opportunity: "blue",
    feature: "green",
    task: "yellow",
    issue: "red",
    jtbd: "purple"
  }.freeze

  enum :card_type, { opportunity: 0, feature: 1, task: 2, issue: 3, jtbd: 4 }, prefix: :type
  enum :stage, STAGES.each_with_index.to_h { |s, i| [s.to_sym, i] }, prefix: :stage
  enum :priority, { critical: 0, high: 1, medium: 2, low: 3 }

  belongs_to :product
  belongs_to :owner, class_name: "User"
  belongs_to :parent, class_name: "Card", optional: true

  has_many :children, class_name: "Card", foreign_key: :parent_id, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :external_links, dependent: :destroy
  has_many :card_key_results, dependent: :destroy
  has_many :key_results, through: :card_key_results

  validates :title, presence: true

  acts_as_list scope: [:product_id, :stage]

  scope :in_stage, ->(stage_name) { where(stage: stages[stage_name.to_s]) }
  scope :ordered, -> { order(position: :asc) }

  def type_color
    TYPE_COLORS[card_type.to_sym] || "gray"
  end

  def current_gate_requirements
    GATE_REQUIREMENTS[stage.to_sym] || []
  end

  def gate_complete?(gate_key)
    auto_check = AUTO_GATES[gate_key.to_sym]
    if auto_check
      auto_check.call(self)
    else
      gate_checklist.dig(stage, gate_key.to_s) == true
    end
  end

  def all_impacts_recorded?
    return true if card_key_results.empty?
    card_key_results.all? { |ckr| ckr.actual_impact.present? }
  end

  def gate_completion_count
    requirements = current_gate_requirements
    return [0, 0] if requirements.empty?

    completed = requirements.count { |r| gate_complete?(r) }
    [completed, requirements.length]
  end

  def can_advance?
    completed, total = gate_completion_count
    completed == total
  end

  def initialize_gate_checklist!
    self.gate_checklist = GATE_REQUIREMENTS.transform_values do |requirements|
      requirements.index_with { false }
    end
  end
end
