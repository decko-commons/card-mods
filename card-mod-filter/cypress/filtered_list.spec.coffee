
input = (content) ->
  cy.ensure "friends+*right+*input_type", type: "phrase", content: content

describe 'editing filtered list', () ->
  before ->
    cy.login()

  specify 'create with filtered list input', () ->
    input "filtered list"

    cy.visit("/Joe User+friends")
    cy.get("._add-item-link").click()
    cy.contains("Select Item")
    cy.contains("button", "More Filters").click()
    cy.contains("a","Name").click()
    cy.get("._filter-container [name='filter[name]']").type("Joe{enter}").then ->
      cy.get("._search-checkbox-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")
      cy.contains(/select\s+3\s+following/)
      cy.get("input._select-all").click()
      # cy.contains(/select\s+0\s+following/)
      cy.get("._add-selected").click().should("not.contain", "input._select-all")
      cy.get("._filtered-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")

      cy.get("._add-item-link").click()
      cy.get(".sort-in-filter-form select").select2("Alphabetical")
      cy.get("input[name='Big Brother']").click()
      cy.get("._add-selected").click()
      cy.get("._filtered-list")
        .should("contain", "Joe Camel")
        .should("contain", "Big Brother")
        .should("not.contain", "u1")
