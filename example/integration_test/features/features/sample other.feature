Feature: Counter decreise
    
    Background:
        Given the app is running
    
    After:
        # Just for the demo purpose, you may write "I don't see {'surprise'} text" to use built-in step instead.
        # See the list of built-in step below.
        And I do not see {'surprise'} text 

    Scenario: Add button twice increments the counter
        When I tap {Icons.add} icon
        And I tap {Icons.add} icon more
        Then I see {'2'} text