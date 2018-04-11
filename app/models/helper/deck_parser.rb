class DeckParser

  def self.run(deck, deck_list)
    list = deck_list.strip.split("\n")
    list.each do |line|
      line.strip!

      name = line.sub(/\A[0-9]+x\s/, "").strip
      quantity = line.match(/\A[0-9]+/)[0].strip.to_i

      card = Card.where("name like ?", name).first || assign_attribute(name)

      deck_cards = DeckCard.find_or_create_by(deck_id: deck.id, card_id: card.id)
      deck_cards.quantity = quantity
      deck_cards.save
    end
  end

  private

  def assign_attribute(name)
    db_card = MTG::Card.where(name: name).all.first
    Card.find_or_create_by(name: db_name).tap do |card|
      card.cost = db_card.mana_cost
      card.card_type = db_card.types.join(" ")
      # card.card_supertype = db_card.supertypes.join(" ") if !!db_card.supertypes
      card.card_subtype = db_card.subtypes.join(" ") if !!db_card.subtypes
      card.card_text = db_card.text
      card.power = db_card.power
      card.toughness = db_card.toughness
      card.save
    end
  end

end
