using AveragedCircuitEigenvalueSampling, JLD2
enter_folder("scalable_aces")
# Set up the parameters
dist = 3
r_1 = 0.075 / 100
r_2 = 0.5 / 100
r_m = 2.0 / 100
total_std_log = sqrt(log(10 / 9))
seed = UInt(0)
shots_set = [10^6; 10^7; 10^8]
repetitions = 1000
rotated_param = RotatedPlanarParameters(dist)
dep_param = DepolarisingParameters(r_1, r_2, r_m)
log_param = LognormalParameters(r_1, r_2, r_m, total_std_log; seed = seed)
# Load the design
metadata_dict = load("data/design_metadata_$(code_filename(rotated_param)).jld2")
@assert rotated_param == metadata_dict["rotated_param"]
@assert dep_param == metadata_dict["dep_param"]
dep_param_set = metadata_dict["dep_param_set"]
tuple_number_set = metadata_dict["tuple_number_set"]
repeat_numbers_set = metadata_dict["repeat_numbers_set"]
dep_idx = 14
@assert dep_param == dep_param_set[dep_idx]
d = load_design(
    rotated_param,
    dep_param_set[dep_idx],
    tuple_number_set[dep_idx],
    repeat_numbers_set[dep_idx],
    true,
)
@assert d.code.noise_param == dep_param
d_log = update_noise(d, log_param)
# Generate the trivial design
code = Code(rotated_param, dep_param)
basic_tuple_set = get_basic_tuple_set(code)
d_basic = generate_design(code, basic_tuple_set)
@assert d_basic.code.noise_param == dep_param
d_basic_log = update_noise(d_basic, log_param)
# Simualte ACES for the optimised design and depolarising noise
aces_data_dep =
    simulate_aces(d, shots_set; repetitions = repetitions, seed = seed, save_data = true)
# Simualte ACES for the optimised design and log-normal noise
aces_data_log = simulate_aces(
    d_log,
    shots_set;
    repetitions = repetitions,
    seed = seed,
    save_data = true,
)
# Simualte ACES for the trivial design and depolarising noise
aces_data_basic_dep = simulate_aces(
    d_basic,
    shots_set;
    repetitions = repetitions,
    seed = seed,
    save_data = true,
)
# Simualte ACES for the trivial design and log-normal noise
aces_data_basic_log = simulate_aces(
    d_basic_log,
    shots_set;
    repetitions = repetitions,
    seed = seed,
    save_data = true,
)
