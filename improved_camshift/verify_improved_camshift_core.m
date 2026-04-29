function verify_improved_camshift_core()
% 验证改进 CAMshift 核心组件的基础行为。

params = create_improved_camshift_parameters();
assert(isfield(params, 'searchRadius'), 'Missing searchRadius parameter.');
assert(abs(params.templateUpdateAlpha - 0.05) < 1e-12, 'Unexpected template alpha.');

state = initialize_kalman_state([20, 30], params);
[predictedState, predictedCovariance] = kalman_predict_step(state.state, state.covariance, params);
assert(all(size(predictedState) == [4, 1]), 'Predicted state size mismatch.');
assert(all(size(predictedCovariance) == [4, 4]), 'Predicted covariance size mismatch.');

observation = [22; 31];
[updatedState, updatedCovariance] = kalman_update_step(predictedState, predictedCovariance, observation, params);
assert(updatedState(1) > predictedState(1), 'Kalman update did not move toward observation.');
assert(updatedCovariance(1, 1) < predictedCovariance(1, 1), 'Kalman update should reduce uncertainty.');

frame = zeros(40, 40, 'uint8');
template = uint8(reshape(1:25, 5, 5) * 4);
frame(16:20, 18:22) = template;
testParams = params;
testParams.searchRadius = 2;
predictedCenter = [18, 20];
windowInfo = extract_search_window(frame, predictedCenter, [5, 5], testParams);
assert(isequal(windowInfo.topLeft, [15, 17]), 'Unexpected search window origin.');

patch = zeros(9, 9, 'uint8');
patch(3:7, 4:8) = template;
response = compute_ncc_response(patch, template);
assert(abs(response.bestScore - 1) < 1e-9, 'NCC score should be perfect for identical patch.');
assert(isequal(response.bestLocation, [3, 4]), 'Unexpected NCC peak location.');

[updatedTemplate, didUpdate] = update_adaptive_template(template, template, 0.95, false, params);
assert(didUpdate, 'Template should update for confident observation.');
assert(isequal(updatedTemplate, template), 'Template EMA should preserve identical template.');

[blockedTemplate, blockedUpdate] = update_adaptive_template(template, template, 0.95, true, params);
assert(~blockedUpdate, 'Template update should skip near borders.');
assert(isequal(blockedTemplate, template), 'Template should remain unchanged when skipped.');

disp('IMPROVED_CAMSHIFT_CORE_OK');
end
