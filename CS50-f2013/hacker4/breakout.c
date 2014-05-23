//
// breakout.c
//
// Computer Science 50
// Problem Set 4
//
// Jeremy Watson
// jeremymwatson@gmail.com
// 10/10/13
//


// standard libraries
#define _XOPEN_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// Stanford Portable Library
#include "gevents.h"
#include "gobjects.h"
#include "gwindow.h"

// height and width of game's window in pixels
#define HEIGHT 600
#define WIDTH 400

// number of rows of bricks
#define ROWS 5

// number of columns of bricks
#define COLS 10

// radius of ball in pixels
#define RADIUS 10

// lives
#define LIVES 3

// seperation between bricks
#define BRICK_SEP 4

// brick height
#define BRICK_HEIGHT 8

// brick width
#define BRICK_WIDTH ((WIDTH - (COLS + 1) * BRICK_SEP) / (double)COLS)

// paddle width
#define PADDLE_WIDTH (1.5 * BRICK_WIDTH)

// paddle height
#define PADDLE_HEIGHT 10

// distance from bottom of window to paddle
#define PADDLE_OFFSET (HEIGHT - 40)



// prototypes
void initBricks(GWindow window);
GOval initBall(GWindow window);
GRect initPaddle(GWindow window);
GLabel initScoreboard(GWindow window);
void updateScoreboard(GWindow window, GLabel label, int points);
GObject detectCollision(GWindow window, GOval ball);
char* brickColor(int rowNum);

int main(int argc, char* argv[])
{
    // seed pseudorandom number generator
    srand48(time(NULL));

    // instantiate window
    GWindow window = newGWindow(WIDTH, HEIGHT);

    // instantiate bricks
    initBricks(window);

    // instantiate ball, centered in middle of window
    GOval ball = initBall(window);

    // instantiate paddle, centered at bottom of window
    GRect paddle = initPaddle(window);

    // instantiate scoreboard, centered in middle of window, just above ball
    GLabel label = initScoreboard(window);

    // number of bricks initially
    int bricks = COLS * ROWS;

    // number of lives initially
    int lives = LIVES;

    // number of points initially
    int points = 0;

    // horizontal & vertical velocity
    double xVelocity = (drand48() - .5) * 4;
    double yVelocity = 2;

    // check for GODMODE
    bool godMode = false;
    if (argc == 2)
    {
        if (strcmp(argv[1], "GOD") == 0)
        {
            godMode = true;
        }    

    }


    // keep playing until game over
    while (lives > 0 && bricks > 0)
    {


        GObject object = detectCollision(window, ball);
        if (object != NULL)
        {
            // determine behavior based on collided object
            if (object == paddle)
            {
                // bounce ball back up and change bounce angle based on collision location with paddle
                yVelocity = -yVelocity;
                xVelocity = ((getX(ball) + RADIUS) - (getX(paddle) + getWidth(paddle) / 2)) / 10;
            }
            else if (object != label) 
            {
                // adds points based on which row brick is from
                points += ROWS - (getY(object) - 30) / (BRICK_HEIGHT + BRICK_SEP);
            
                removeGWindow(window, detectCollision(window, ball));
                yVelocity = -yVelocity;

                // decreases paddle size slowly based on remaining bricks, minimum of half original size
                if (getWidth(paddle) > PADDLE_WIDTH / 2)
                {    
                    setSize(paddle, PADDLE_WIDTH * (( 2.0 * (ROWS * COLS) - points) / (2.0 * (ROWS * COLS))), PADDLE_HEIGHT);
                }
                updateScoreboard(window, label, points); 
                bricks--; 
            }

        }
    
        move(ball, xVelocity, yVelocity);
        
        pause(10);

        // check for collision with edges
        if (getX(ball) + getWidth(ball) >= WIDTH || getX(ball) <= 0)
        {
            xVelocity = -xVelocity;
        }        

        if (getY(ball) <= 0)
        {
            yVelocity = -yVelocity;
        }        
    
        // reset ball and reduce lives if ball touches bottom
        if (getY(ball) + getHeight(ball) >= HEIGHT)
        {
            lives--;
            waitForClick();
            setLocation(ball, WIDTH / 2, HEIGHT / 2);
        }        
        
        // if god mode is not active, move paddle with mouse, else paddle moves automagically
        if (godMode == false)
        {
            // move paddle with mouse
            GEvent event = getNextEvent(MOUSE_EVENT);
            if (event != NULL)
            {
                if (getEventType(event) == MOUSE_MOVED)
                {
                    setLocation(paddle, getX(event) - (PADDLE_WIDTH / 2), PADDLE_OFFSET);
                }
            }
        }
        else
        {
            // drand used to encourage variety in ball angle to finish game faster
            setLocation(paddle, (getX(ball) + RADIUS) - (getWidth(paddle) / 2) - (drand48() - .5) * 9, PADDLE_OFFSET);
        }
        
    }

    // wait for click before exiting
    waitForClick();

    // game over
    closeGWindow(window);
    return 0;
}

/**
 * Initializes window with a grid of bricks.
 */
void initBricks(GWindow window)
{
    for (int i = 0; i < ROWS; i++)
    {
        for (int j = 0; j < COLS; j++)
        {
            GRect brick = newGRect(BRICK_SEP + ((BRICK_SEP + BRICK_WIDTH) * j), 30 + ((BRICK_SEP + BRICK_HEIGHT) * i), BRICK_WIDTH, BRICK_HEIGHT);
            setColor(brick, brickColor(i));
            setFilled(brick, true);
            add(window, brick);
        }

    }

}

/**
 * Instantiates ball in center of window.  Returns ball.
 */
GOval initBall(GWindow window)
{

    GOval ball = newGOval((WIDTH + RADIUS) / 2, (HEIGHT + RADIUS) / 2, 2 * RADIUS, 2 * RADIUS);     
    setColor(ball, "BLACK");
    setFilled(ball, true);
    add(window, ball);
    return ball;
}

/**
 * Instantiates paddle in bottom-middle of window.
 */
GRect initPaddle(GWindow window)
{
    GRect paddle = newGRect((WIDTH - PADDLE_WIDTH) / 2, PADDLE_OFFSET, PADDLE_WIDTH, PADDLE_HEIGHT);
    setColor(paddle, "BLUE");
    setFilled(paddle, true);
    add(window, paddle);

    return paddle;
}

/**
 * Instantiates, configures, and returns label for scoreboard.
 */
GLabel initScoreboard(GWindow window)
{

    GLabel label = newGLabel("0");
    setFont(label, "SansSerif-36");
    setColor(label, "GRAY");
    double x = (getWidth(window) - getWidth(label)) / 2;
    double y = (getHeight(window) - getHeight(label)) / 2;
    setLocation(label, x, y);
    add(window, label);
    return label;
}

/**
 * Updates scoreboard's label, keeping it centered in window.
 */
void updateScoreboard(GWindow window, GLabel label, int points)
{
    // update label
    char s[12];
    sprintf(s, "%i", points);
    setLabel(label, s);

    // center label in window
    double x = (getWidth(window) - getWidth(label)) / 2;
    double y = (getHeight(window) - getHeight(label)) / 2;
    setLocation(label, x, y);
}

/**
 * Detects whether ball has collided with some object in window
 * by checking the four corners of its bounding box (which are
 * outside the ball's GOval, and so the ball can't collide with
 * itself).  Returns object if so, else NULL.
 */
GObject detectCollision(GWindow window, GOval ball)
{
    // ball's location
    double x = getX(ball);
    double y = getY(ball);

    // for checking for collisions
    GObject object;

    // check for collision at ball's top-left corner
    object = getGObjectAt(window, x, y);
    if (object != NULL)
    {
        return object;
    }

    // check for collision at ball's top-right corner
    object = getGObjectAt(window, x + 2 * RADIUS, y);
    if (object != NULL)
    {
        return object;
    }

    // check for collision at ball's bottom-left corner
    object = getGObjectAt(window, x, y + 2 * RADIUS);
    if (object != NULL)
    {
        return object;
    }

    // check for collision at ball's bottom-right corner
    object = getGObjectAt(window, x + 2 * RADIUS, y + 2 * RADIUS);
    if (object != NULL)
    {
        return object;
    }

    // no collision
    return NULL;
}

// returns a color for use by the initBricks function
char* brickColor(int rowNum)
{
    switch (rowNum)
    {
        case 0:
            return "RED";
        case 1:
            return "ORANGE";
        case 2:
            return "YELLOW";
        case 3:
            return "GREEN";
        case 4:
            return "BLUE";
        default:
            return "BLACK";
    }
}

