-- Copyright 2016 The Cartographer Authors
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

include "map_builder.lua"
include "trajectory_builder.lua"

options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map",
  tracking_frame = "base_footprint",
  published_frame = "odom",
  odom_frame = "odom",
  provide_odom_frame = false,
  publish_frame_projected_to_2d = true,
  use_odometry = true,
  use_nav_sat = false,
  use_landmarks = false,
  num_laser_scans = 1,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 0,
  lookup_transform_timeout_sec = 1.0,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 10e-3,
  trajectory_publish_period_sec = 30e-3,
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 1.,
  landmarks_sampling_ratio = 1.,
}

MAP_BUILDER.use_trajectory_builder_2d = true
MAP_BUILDER.num_background_threads = 6

-- _____________________________________________________________________________________________________________________________
-- _TRAJECTORY_BUILDER_/ LOCAL SLAM_____________________________________________________________________________________________

-- TRAJECTORY_BUILDER_2D.num_accumulated_range_data = 10
TRAJECTORY_BUILDER_2D.submaps.num_range_data = 10
TRAJECTORY_BUILDER_2D.min_range = 0.3
TRAJECTORY_BUILDER_2D.max_range = 15.
TRAJECTORY_BUILDER_2D.use_imu_data = false
TRAJECTORY_BUILDER_2D.missing_data_ray_length = 0

TRAJECTORY_BUILDER_2D.use_online_correlative_scan_matching = true
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.linear_search_window = .3
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.angular_search_window = math.rad(30.0)
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.translation_delta_cost_weight = 20
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.rotation_delta_cost_weight = .1

-- To avoid inserting too many scans per submaps, once a motion between two scans is found by the scan matcher, it goes through a motion filter. A scan is dropped if the motion that led to it is not considered as significant enough. A scan is inserted into the current submap only if its motion is above a certain distance, angle or time threshold.
TRAJECTORY_BUILDER_2D.motion_filter.max_angle_radians = math.rad(5.0)
TRAJECTORY_BUILDER_2D.motion_filter.max_distance_meters = 0.1
TRAJECTORY_BUILDER_2D.motion_filter.max_time_seconds = 1.0

-- # Use if you want to add more weight to the odometry translation and rotation
-- Either way, the CeresScanMatcher can be configured to give a certain weight to each of its input. The weight is a measure of trust into your data (bigger values have more trust), this can be seen as a static covariance. The unit of weight parameters are dimensionless quantities and can’t be compared between each others. The bigger the weight of a source of data is, the more emphasis Cartographer will put on this source of data when doing scan matching. Sources of data include occupied space (points from the scan), translation and rotation from the pose extrapolator (or RealTimeCorrelativeScanMatcher)
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.translation_weight = 200
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.rotation_weight = 5

-- TRAJECTORY_BUILDER_2D.submaps.num_laser_fans = 35
-- TRAJECTORY_BUILDER_2D.submaps.resolution = 0.035

-- TRAJECTORY_BUILDER_2D.use_online_correlative_scan_matching = true

-- _____________________________________________________________________________________________________________________________
-- _POSE_GRAPH_/_GLOBAL SLAM____________________________________________________________________________________________________

--Setting POSE_GRAPH.optimize_every_n_nodes to 0 is a handy way to disable global SLAM and concentrate on the behavior of local SLAM. This is usually one of the first thing to do to tune Cartographer.

POSE_GRAPH.optimize_every_n_nodes = 1
-- POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 10
-- POSE_GRAPH.optimization_problem.huber_scale = 5e2

POSE_GRAPH.global_sampling_ratio = 1.
POSE_GRAPH.constraint_builder.sampling_ratio = 1.

POSE_GRAPH.constraint_builder.min_score = 0.71
POSE_GRAPH.constraint_builder.global_localization_min_score = 0.75
POSE_GRAPH.constraint_builder.log_matches = false
POSE_GRAPH.constraint_builder.sampling_ratio = 0.03
-- POSE_GRAPH.constraint_builder.min_score = 0.62
-- POSE_GRAPH.constraint_builder.log_matches = true

POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher.angular_search_window = math.rad(15.)
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher.linear_search_window = 0.3

return options
