#define MAP_STATE_CLEAR 0x00
#define MAP_STATE_OBSTACLE 0x01
#define MAP_STATE_BOUNDARY 0x02
#define MAP_STATE_VISITED 0x04
#define MAP_STATE_NORTH 0x08
#define MAP_STATE_EAST 0x10
#define MAP_STATE_SOUTH 0x20
#define MAP_STATE_WEST 0x40

#define DATA_CLEAR '.'
#define DATA_OBSTACLE '#'
#define DATA_START '^'
#define DATA_BOUNDARY '\n'

#define MOVEMENT_NORTH 0x01
#define MOVEMENT_EAST 0x02
#define MOVEMENT_SOUTH 0x03
#define MOVEMENT_WEST 0x04

#define MAX_ITERATIONS 10000

struct map
{
    int size;
    int width;
    int pos_x;
    int pos_y;
    int movement;

    unsigned char *data;
};

int main(int argc, char *argv[]);
int read_data(char *filename, struct map *map);
int convert_map_data(struct map *map);
int set_map_state(struct map *map, int x, int y, unsigned char state);
int get_map_state(struct map *map, int x, int y);
int print_map(struct map *map);
int is_path_blocked(struct map *map);
int move_step(struct map *map);
int get_next_position(struct map *map, int *x, int *y);
int turn_clockwise(struct map *map);
int leaving_map_next(struct map *map);
int is_out_of_bounds(struct map *map, int x, int y);
int count_visited(struct map *map);
int print_position_state(struct map *map);
int print_direction(struct map *map);
struct map *copy_map(struct map *map);
int free_map(struct map *map);
int get_direction_state(int direction);
int test_blocking(struct map *map);
int check_loop(struct map *map);
