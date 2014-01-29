%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
% Define ON and OFF keywords
g_ON                              = 1;
g_OFF                             = 0;

% Define Drawing Modes
g_DRAWING_OFF                     = g_OFF;
g_DRAWING_ON                      = g_ON;
g_DRAWING_MODE                    = g_DRAWING_ON;

% Define for the Algo mode (one shot VS. continuous)
g_ALGO_MODE_ONE_SHOT              = 1;
g_ALGO_MODE_CONTINUOUS_STREAMING  = 2;
g_ALGO_MODE                       = g_ALGO_MODE_ONE_SHOT;
g_ALGO_UPLOAD_MODE_FULL_CAPACITY  = 1;
g_ALGO_UPLOAD_MODE_RELEVANT_ONLY  = 2;
g_ALGO_UPLOAD_MODE_WAIT_PUSH      = 3;
g_ALGO_UPLOAD_MODE                = g_ALGO_UPLOAD_MODE_WAIT_PUSH;

% Define Activity-specific Constants
g_SPRINTING_MAG_THRESHOLD         = 1005;
g_SPRINTING_DISC_THRESHOLD        = 1200;
g_RUNNING_DISC_THRESHOLD          = 1000;
g_JUMPING_DISC_THRESHOLD          = 1700;
g_JUMPING_MAGN_THRESHOLD          = 2250;
g_MIN_NUM_SAMPLES_BETWEEN_CYCLES  = 100;
g_MAX_NUM_SAMPLES_BETWEEN_CYCLES  = 400;
g_MAG_THRESHOLD                   = g_SPRINTING_MAG_THRESHOLD;
g_DISC_THRESHOLD                  = g_SPRINTING_DISC_THRESHOLD;
 
% Define Simulation Constants
g_SENSOR_HARDWARE_EMULATION_ON    = g_ON;
g_SENSOR_HARDWARE_EMULATION_OFF   = g_OFF;
g_SENSOR_HARDWARE_EMULATION_MODE  = g_SENSOR_HARDWARE_EMULATION_ON;
g_KEEP_TRACK_OFF_ALL_CYCLES       = g_ON;

% Computer memory specific Constants
g_NUMBER_SAMPLE_CURRENT_BUFFER	= 1600;
g_MAX_NUM_CYCLE_LOCATIONS       = 54;

% Buffer Relevant activity fullness
g_CRITICAL_PERCENT                = 50;
g_MAX_NUM_ELEMENTS                = 16000;
g_MAX_NUMBER_BUFFERS_TO_UPLOAD    = 10;

g_MEMORY_DEBUG                    = g_ON;
g_NUMBER_SAMPLES_BEFORE_FIRST_INTERESTING_SAMPLE = 0;
g_MEANINGLESS_DATA_REQUIRED       = g_ON;
g_WAIT_FOR_FULL_BUFFER            = g_OFF;
g_SAMPLING_FREQUENCY_HZ           = 250;

