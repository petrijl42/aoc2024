#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "program2.h"

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    struct map map;

    if (read_data(argv[1], &map))
    {
        return 1;
    }

    if (convert_map_data(&map))
    {
        return 1;
    }

    /*
    printf("Map size: %d\n", map.size);
    printf("Map width: %d\n", map.width);
    printf("Map position: (%d, %d)\n", map.pos_x, map.pos_y);
    printf("Map movement: %d\n", map.movement);
    */

    int loops = 0;

    for (int i = 0; i < MAX_ITERATIONS; i++)
    {
        if (leaving_map_next(&map))
        {
            break;
        }

        if (is_path_blocked(&map))
        {
            turn_clockwise(&map);
        }
        else
        {
            if (test_blocking(&map))
            {
                loops++;
            }

            if (move_step(&map))
            {
                printf("Error: Unable to move\n");
                return 1;
            }

            set_map_state(&map, map.pos_x, map.pos_y, MAP_STATE_VISITED);
            set_map_state(&map, map.pos_x, map.pos_y, get_direction_state(map.movement));
        }
    }

    printf("Loops: %d\n", loops);
}

int read_data(char *filename, struct map *map)
{
    FILE *file = fopen(filename, "r");
    if (file == NULL)
    {
        printf("Error: Unable to open file %s\n", filename);
        return 1;
    }

    struct stat statbuf;
    if (fstat(fileno(file), &statbuf))
    {
        printf("Error: Unable to get file size\n");
        return 1;
    }

    map->data = malloc(statbuf.st_size);
    if (map->data == NULL)
    {
        printf("Error: Unable to allocate memory\n");
        return 1;
    }

    map->size = statbuf.st_size;

    if (fread(map->data, 1, map->size, file) != map->size)
    {
        printf("Error: Unable to read file\n");
        return 1;
    }

    return 0;
}

int convert_map_data(struct map *map)
{
    map->width = 0;
    map->pos_x = 0;
    map->pos_y = 0;
    map->movement = MOVEMENT_NORTH;

    for (int i = 0; i < map->size; i++)
    {
        if (map->data[i] == DATA_BOUNDARY)
        {
            if (!map->width)
            {
                map->width = i + 1;
            }

            map->data[i] = MAP_STATE_BOUNDARY;
        }
        else if (map->data[i] == DATA_CLEAR)
        {
            map->data[i] = MAP_STATE_CLEAR;
        }
        else if (map->data[i] == DATA_OBSTACLE)
        {
            map->data[i] = MAP_STATE_OBSTACLE;
        }
        else if (map->data[i] == DATA_START)
        {
            map->data[i] = MAP_STATE_VISITED;
            map->pos_x = i % map->width;
            map->pos_y = i / map->width;
        }
        else
        {
            printf("Error: Invalid character in map data\n");
            return 1;
        }
    }

    return 0;
}

int set_map_state(struct map *map, int x, int y, unsigned char state)
{
    if (x < 0 || x >= map->width || y < 0 || y >= map->size / map->width)
    {
        return 1;
    }

    map->data[y * map->width + x] |= state;

    return 0;
}

int get_map_state(struct map *map, int x, int y)
{
    if (x < 0 || x >= map->width || y < 0 || y >= map->size / map->width)
    {
        return -1;
    }

    return map->data[y * map->width + x];
}

int print_map(struct map *map)
{
    for (int i = 0; i < map->size; i++)
    {
        if (map->data[i] & MAP_STATE_BOUNDARY)
        {
            printf("\n");
        }
        else if (map->data[i] & MAP_STATE_OBSTACLE)
        {
            printf("#");
        }
        else if (map->data[i] & MAP_STATE_VISITED)
        {
            printf("X");
        }
        else
        {
            printf(".");
        }
    }

    printf("\n");

    return 0;
}

int is_path_blocked(struct map *map)
{
    int x = map->pos_x;
    int y = map->pos_y;

    if (get_next_position(map, &x, &y))
    {
        printf("Error: Unable to get next position\n");
        return 1;
    }

    return get_map_state(map, x, y) & MAP_STATE_OBSTACLE;
}

int move_step(struct map *map)
{
    int x = map->pos_x;
    int y = map->pos_y;

    if (get_next_position(map, &x, &y))
    {
        printf("Error: Unable to get next position\n");
        return 1;
    }

    map->pos_x = x;
    map->pos_y = y;

    return 0;
}

int get_next_position(struct map *map, int *x, int *y)
{
    int next_x = *x;
    int next_y = *y;

    switch (map->movement)
    {
    case MOVEMENT_NORTH:
        next_y--;
        break;
    case MOVEMENT_EAST:
        next_x++;
        break;
    case MOVEMENT_SOUTH:
        next_y++;
        break;
    case MOVEMENT_WEST:
        next_x--;
        break;
    }

    *x = next_x;
    *y = next_y;

    return 0;
}

int turn_clockwise(struct map *map)
{
    switch (map->movement)
    {
    case MOVEMENT_NORTH:
        map->movement = MOVEMENT_EAST;
        break;
    case MOVEMENT_EAST:
        map->movement = MOVEMENT_SOUTH;
        break;
    case MOVEMENT_SOUTH:
        map->movement = MOVEMENT_WEST;
        break;
    case MOVEMENT_WEST:
        map->movement = MOVEMENT_NORTH;
        break;
    }

    return 0;
}

int leaving_map_next(struct map *map)
{
    int x = map->pos_x;
    int y = map->pos_y;

    if (get_next_position(map, &x, &y))
    {
        printf("Error: Unable to get next position\n");
        return 1;
    }

    return is_out_of_bounds(map, x, y);
}

int is_out_of_bounds(struct map *map, int x, int y)
{
    int out_of_bounds = 0;
    if (x < 0 || y < 0)
    {
        out_of_bounds = 1;
    }
    else if (y * map->width + x >= map->size)
    {
        out_of_bounds = 1;
    }
    else if (get_map_state(map, x, y) & MAP_STATE_BOUNDARY)
    {
        out_of_bounds = 1;
    }

    return out_of_bounds;
    // return x < 0 || x >= map->width || y < 0 || y >= map->size / map->width;
}

int count_visited(struct map *map)
{
    int count = 0;

    for (int i = 0; i < map->size; i++)
    {
        if (map->data[i] & MAP_STATE_VISITED)
        {
            count++;
        }
    }

    return count;
}

int print_position_state(struct map *map)
{
    printf("Position: (%d, %d)\n", map->pos_x, map->pos_y);

    if (is_out_of_bounds(map, map->pos_x, map->pos_y))
    {
        printf("Out of bounds\n");
    }
    else
    {
        if (map->data[map->pos_y * map->width + map->pos_x] & MAP_STATE_VISITED)
        {
            printf("Visited\n");
        }
        if (map->data[map->pos_y * map->width + map->pos_x] & MAP_STATE_OBSTACLE)
        {
            printf("Obstacle\n");
        }
        if (map->data[map->pos_y * map->width + map->pos_x] & MAP_STATE_BOUNDARY)
        {
            printf("Boundary\n");
        }
        if (map->data[map->pos_y * map->width + map->pos_x] == MAP_STATE_CLEAR)
        {
            printf("Not visited\n");
        }
    }

    return 0;
}

int print_direction(struct map *map)
{
    switch (map->movement)
    {
    case MOVEMENT_NORTH:
        printf("North\n");
        break;
    case MOVEMENT_EAST:
        printf("East\n");
        break;
    case MOVEMENT_SOUTH:
        printf("South\n");
        break;
    case MOVEMENT_WEST:
        printf("West\n");
        break;
    }

    return 0;
}

struct map *copy_map(struct map *map)
{
    struct map *new_map = malloc(sizeof(struct map));

    if (new_map == NULL)
    {
        return NULL;
    }

    new_map->size = map->size;
    new_map->width = map->width;
    new_map->pos_x = map->pos_x;
    new_map->pos_y = map->pos_y;
    new_map->movement = map->movement;

    new_map->data = malloc(sizeof(char) * new_map->size);
    if (new_map->data == NULL)
    {
        free(new_map);
        return NULL;
    }

    memcpy(new_map->data, map->data, sizeof(char) * new_map->size);

    return new_map;
}

int free_map(struct map *map)
{
    free(map->data);
    free(map);

    return 0;
}

int get_direction_state(int direction)
{
    if (direction == MOVEMENT_NORTH)
    {
        return MAP_STATE_NORTH;
    }
    else if (direction == MOVEMENT_EAST)
    {
        return MAP_STATE_EAST;
    }
    else if (direction == MOVEMENT_SOUTH)
    {
        return MAP_STATE_SOUTH;
    }
    else if (direction == MOVEMENT_WEST)
    {
        return MAP_STATE_WEST;
    }
}

int test_blocking(struct map *map)
{
    int x = map->pos_x;
    int y = map->pos_y;

    if (get_next_position(map, &x, &y))
    {
        printf("Error: Unable to get next position\n");
        return 0;
    }
    if (is_out_of_bounds(map, x, y))
    {
        return 0;
    }

    if (get_map_state(map, x, y) & MAP_STATE_VISITED)
    {
        return 0;
    }

    struct map *new_map = copy_map(map);

    if (new_map == NULL)
    {
        return 0;
    }

    if (set_map_state(new_map, x, y, MAP_STATE_OBSTACLE))
    {
        printf("Error: Unable to set map state\n");
        return 0;
    }

    int is_loop = 0;
    if (check_loop(new_map))
    {
        is_loop = 1;
    }

    free_map(new_map);
    return is_loop;
}

int check_loop(struct map *map)
{
    for (int i = 0; i < MAX_ITERATIONS; i++)
    {
        if (leaving_map_next(map))
        {
            return 0;
        }

        if (is_path_blocked(map))
        {
            turn_clockwise(map);
        }
        else
        {
            if (move_step(map))
            {
                printf("Error: Unable to move\n");
                return 0;
            }

            int state = get_map_state(map, map->pos_x, map->pos_y);

            if (state & MAP_STATE_VISITED && state & get_direction_state(map->movement))
            {
                return 1;
            }

            set_map_state(map, map->pos_x, map->pos_y, MAP_STATE_VISITED);
            set_map_state(map, map->pos_x, map->pos_y, get_direction_state(map->movement));
        }
    }

    printf("Error: Maximum iterations reached\n");

    return 0;
}